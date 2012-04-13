#import "JFFURLConnection.h"
#import "JNAbstractConnection+Constructor.h"

#import "JFFURLResponse.h"

#import "JNHttpDecoder.h"
#import "JNHttpEncodingsFactory.h"
#import "JNConstants.h"

#import "JFFURLConnectionParams.h"
#import "JFFLocalCookiesStorage.h"

#import <JFFUtils/JFFError.h>

@interface JFFURLConnection ()

@property ( nonatomic, retain ) JFFURLConnectionParams* params;

//JTODO move to ARC and remove inner properties

@property ( nonatomic, assign ) BOOL responseHandled;
@property ( nonatomic, retain ) __attribute__((NSObject)) CFReadStreamRef readStream;

@property ( nonatomic, retain ) JFFURLResponse* urlResponse;

-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_;

-(void)cancel;

-(void)closeReadStream;

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_;
-(void)handleData:( void* )buffer_ length:( NSUInteger )length_;
-(void)handleFinish:( NSError* )error_;

@end

static void readStreamCallback( CFReadStreamRef stream_
                               , CFStreamEventType event_
                               , void* selfContext_ )
{
    JFFURLConnection* self_ = selfContext_;
    switch( event_ )
    {
        case kCFStreamEventHasBytesAvailable:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            UInt8 buffer_[ kJNMaxBufferSize ];
            CFIndex bytesRead_ = CFReadStreamRead( stream_, buffer_, kJNMaxBufferSize );
            if ( bytesRead_ > 0 )
            {
                [ self_ handleData: buffer_
                            length: bytesRead_ ];
            }
            break;
        }
        case kCFStreamEventErrorOccurred:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            CFStreamError error_ = CFReadStreamGetError( stream_ );
            NSString* errorDescription_ = [ NSString stringWithFormat: @"CFStreamError domain: %d", error_.domain ];

            [ self_ handleFinish: [ JFFError errorWithDescription: errorDescription_
                                                             code: error_.error ] ];
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            [ self_ handleFinish: nil ];
            break;
        }
    }
}

@implementation JFFURLConnection

@synthesize responseHandled = _responseHandled;

@synthesize urlResponse = _urlResponse;
@synthesize readStream  = _readStream;

@synthesize params = _params;

-(void)dealloc
{
    [ self cancel ];

    self.urlResponse = nil;
    self.params      = nil;

    [ super dealloc ];
}

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_
{
    self = [ super privateInit ];

    if ( self )
    {
        self.params = params_;
    }

    return self;
}

-(void)start
{
    [ self startConnectionWithPostData: self.params.httpBody
                               headers: self.params.headers ];
}

-(void)applyCookiesForHTTPRequest:( CFHTTPMessageRef )httpRequest_
{
    //JTODO refactor 1
    NSArray* availableCookies_ = nil;
    if ( self.params.cookiesStorage )
    {
        availableCookies_ = [ self.params.cookiesStorage cookiesForURL: self.params.url ];
    }
    else
    {
        availableCookies_ = [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] cookiesForURL: self.params.url ];
    }

    NSDictionary* headers_ = [ NSHTTPCookie requestHeaderFieldsWithCookies: availableCookies_ ];

    [ headers_ enumerateKeysAndObjectsUsingBlock: ^( id key_, id value_, BOOL *stop )
    {
        CFHTTPMessageSetHeaderFieldValue ( httpRequest_, (CFStringRef)key_, (CFStringRef)value_ );
    } ];
}

//JTODO add timeout and test
//JTODO test invalid url
//JTODO test no internet connection
-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_
{
    CFStringRef method_ = (CFStringRef) (self.params.httpMethod ?: @"GET");
    if ( !self.params.httpMethod && data_ )
    {
        method_ = (CFStringRef) @"POST";
    }

    CFHTTPMessageRef httpRequest_ = CFHTTPMessageCreateRequest( NULL
                                                               , method_
                                                               , (CFURLRef)self.params.url
                                                               , kCFHTTPVersion1_1 );

    [ self applyCookiesForHTTPRequest: httpRequest_ ];

    if ( data_ )
    {
        CFHTTPMessageSetBody ( httpRequest_, (CFDataRef)data_ );
    }

    [ headers_ enumerateKeysAndObjectsUsingBlock: ^( id header_, id headerValue_, BOOL *stop )
    {
        CFHTTPMessageSetHeaderFieldValue( httpRequest_
                                         ,(CFStringRef)header_
                                         ,(CFStringRef)headerValue_ );
    } ];

    //   CFReadStreamCreateForStreamedHTTPRequest( CFAllocatorRef alloc,
    //                                             CFHTTPMessageRef requestHeaders,
    //                                             CFReadStreamRef	requestBody )
    _readStream = CFReadStreamCreateForHTTPRequest( NULL, httpRequest_ );
    CFRelease( httpRequest_ );

    //Prefer using keep-alive packages
    Boolean keepAliveSetResult_ = CFReadStreamSetProperty( self.readStream, kCFStreamPropertyHTTPAttemptPersistentConnection, kCFBooleanTrue );
    if ( FALSE == keepAliveSetResult_ )
    {
        NSLog( @"JFFURLConnection->start : unable to setup keep-alive packages" );
    }

    typedef void* (*retain)( void* info_ );
    typedef void (*release)( void* info_ );
    CFStreamClientContext streamContext_ = { 0, self, (retain)CFRetain, (release)CFRelease, NULL };

    CFOptionFlags registered_events_ = kCFStreamEventHasBytesAvailable
        | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    if ( CFReadStreamSetClient( self.readStream, registered_events_, readStreamCallback, &streamContext_ ) )
    {
        CFReadStreamScheduleWithRunLoop( self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
    }

    CFReadStreamOpen( self.readStream );
}

-(void)closeReadStream
{
    if ( _readStream )
    {
        CFReadStreamUnscheduleFromRunLoop( _readStream
                                          , CFRunLoopGetCurrent()
                                          , kCFRunLoopCommonModes );
        CFReadStreamClose( _readStream );
        self.readStream = nil;
    }
}

-(void)closeStreams
{
    [ self closeReadStream ];
}

-(void)cancel
{
    [ self closeStreams ];
    [ self clearCallbacks ];
}

-(void)handleData:( void* )buffer_ 
           length:( NSUInteger )length_
{
    if ( !self.didReceiveDataBlock )
    {
        return;
    }

    NSString* contentEncoding_ = [ self.urlResponse.allHeaderFields
                                  objectForKey: @"Content-Encoding" ];
    id< JNHttpDecoder > decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: contentEncoding_ ];

    NSError* decoderError_ = nil;

    NSData* rawNsData_ = [ NSData dataWithBytes: buffer_ 
                                         length: length_ ];

    NSData* decodedData_ = [ decoder_ decodeData: rawNsData_ 
                                           error: &decoderError_ ];

    if ( nil == decodedData_ )
    {
        [ self handleFinish: decoderError_ ];
    }
    else 
    {
        self.didReceiveDataBlock( decodedData_ );
    }
}

-(void)handleFinish:( NSError* )error_
{
    [ self closeReadStream ];

    if ( self.didFinishLoadingBlock )
    {
        self.didFinishLoadingBlock( error_ );
    }
    [ self clearCallbacks ];
}

-(void)acceptCookiesForHeaders:( NSDictionary* )headers_
{
    NSArray* cookies_ = [ NSHTTPCookie cookiesWithResponseHeaderFields: headers_
                                                                forURL: self.params.url ];
    //JTODO refactor 1
    if ( self.params.cookiesStorage )
    {
        [ self.params.cookiesStorage setCookies: cookies_ ];
    }
    else
    {
        for ( NSHTTPCookie* cookie_ in cookies_ )
        {
            [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] setCookie: cookie_ ];
        }
    }
}

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_
{
    if ( self.responseHandled )
    {
        return;
    }

    CFHTTPMessageRef response_ = (CFHTTPMessageRef)CFReadStreamCopyProperty( stream_, kCFStreamPropertyHTTPResponseHeader );
    if ( response_ )
    {
        self.responseHandled = YES;

        CFDictionaryRef allHeaders_ = CFHTTPMessageCopyAllHeaderFields( response_ );
        [ self acceptCookiesForHeaders: (NSDictionary*)allHeaders_ ];

        if ( self.didReceiveResponseBlock )
        {
            CFIndex statusCode_ = CFHTTPMessageGetResponseStatusCode( response_ );

            JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];
            urlResponse_.statusCode = statusCode_;

            urlResponse_.allHeaderFields = (NSDictionary*)allHeaders_;

            self.didReceiveResponseBlock( urlResponse_ );
            self.didReceiveResponseBlock = nil;

            self.urlResponse = urlResponse_;
            [ urlResponse_ release ];
        }

        CFRelease( allHeaders_ );
        CFRelease( response_ );
    }
}

@end
