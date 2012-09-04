#import "JFFURLConnection.h"

#import "JFFURLResponse.h"

#import "JNHttpDecoder.h"
#import "JNHttpEncodingsFactory.h"
#import "JNConstants.h"

#import "JFFURLConnectionParams.h"
#import "JFFLocalCookiesStorage.h"

#import "NSURL+URLWithLocation.h"

//#define SHOW_DEBUG_LOGS
#import <JFFLibrary/JDebugLog.h>

@interface JFFURLConnection ()

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_;
-(void)handleData:( void* )buffer_ length:( NSUInteger )length_;
-(void)handleFinish:( NSError* )error_;

@end

static void readStreamCallback( CFReadStreamRef stream_
                               , CFStreamEventType event_
                               , void* selfContext_ )
{
    __unsafe_unretained JFFURLConnection* self_ = (__bridge JFFURLConnection*)selfContext_;
    switch( event_ )
    {
        case kCFStreamEventNone:
        {
            break;
        }
        case kCFStreamEventOpenCompleted:
        {
            break;
        }
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
        case kCFStreamEventCanAcceptBytes:
        {
            break;
        }
        case kCFStreamEventErrorOccurred:
        {
            [ self_ handleResponseForReadStream: stream_ ];

            CFStreamError error_ = CFReadStreamGetError( stream_ );
            NSString* errorDescription_ = [ [ NSString alloc ] initWithFormat: @"CFStreamError domain: %ld", error_.domain ];

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
{
    CFReadStreamRef _readStream;
    JFFURLConnectionParams* _params;
    id _cookiesStorage;
    BOOL _responseHandled;
    JFFURLResponse* _urlResponse;
};

-(void)dealloc
{
    [ self cancel ];
}

-(id)initWithURLConnectionParams:( JFFURLConnectionParams* )params_
{
    self = [ super init ];

    if ( self )
    {
        self->_params = params_;
        self->_cookiesStorage = self->_params.cookiesStorage ?: [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    }

    return self;
}

-(void)start
{
    [ self startConnectionWithPostData: self->_params.httpBody
                               headers: self->_params.headers ];
}

-(void)applyCookiesForHTTPRequest:( CFHTTPMessageRef )httpRequest_
{
    NSArray* availableCookies_ = [ _cookiesStorage cookiesForURL: self->_params.url ];

    NSDictionary* headers_ = [ NSHTTPCookie requestHeaderFieldsWithCookies: availableCookies_ ];

    [ headers_ enumerateKeysAndObjectsUsingBlock: ^( id key_, id value_, BOOL *stop )
    {
        CFHTTPMessageSetHeaderFieldValue ( httpRequest_
                                          , (__bridge CFStringRef)key_
                                          , (__bridge CFStringRef)value_ );
    } ];
}

//JTODO add timeout and test
//JTODO test invalid url
//JTODO test no internet connection
-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_
{
    CFStringRef method_ = (__bridge  CFStringRef) (self->_params.httpMethod ?: @"GET");
    if ( !self->_params.httpMethod && data_ )
    {
        method_ = (CFStringRef) @"POST";
    }

    CFHTTPMessageRef httpRequest_ = CFHTTPMessageCreateRequest( NULL
                                                               , method_
                                                               , (__bridge CFURLRef)self->_params.url
                                                               , kCFHTTPVersion1_1 );

    [ self applyCookiesForHTTPRequest: httpRequest_ ];

    if ( data_ )
    {
        CFHTTPMessageSetBody ( httpRequest_, (__bridge CFDataRef)data_ );
    }

    [ headers_ enumerateKeysAndObjectsUsingBlock: ^( id header_, id headerValue_, BOOL *stop )
    {
        CFHTTPMessageSetHeaderFieldValue( httpRequest_
                                         , (__bridge CFStringRef)header_
                                         , (__bridge CFStringRef)headerValue_ );
    } ];

    [ self closeReadStream ];
    //   CFReadStreamCreateForStreamedHTTPRequest( CFAllocatorRef alloc,
    //                                             CFHTTPMessageRef requestHeaders,
    //                                             CFReadStreamRef	requestBody )
    self->_readStream = CFReadStreamCreateForHTTPRequest( NULL, httpRequest_ );
    CFRelease( httpRequest_ );

    //Prefer using keep-alive packages
    Boolean keepAliveSetResult_ = CFReadStreamSetProperty( self->_readStream
                                                          , kCFStreamPropertyHTTPAttemptPersistentConnection
                                                          , kCFBooleanTrue );
    if ( FALSE == keepAliveSetResult_ )
    {
        NSLog( @"JFFURLConnection->start : unable to setup keep-alive packages" );
    }

    typedef void* (*retain)( void* info_ );
    typedef void (*release)( void* info_ );
    CFStreamClientContext streamContext_ = {
        0
        , (__bridge void*)(self)
        , (retain)CFRetain
        , (release)CFRelease
        , NULL };

    CFOptionFlags registered_events_ = kCFStreamEventHasBytesAvailable
        | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    if ( CFReadStreamSetClient( self->_readStream, registered_events_, readStreamCallback, &streamContext_ ) )
    {
        CFReadStreamScheduleWithRunLoop( self->_readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
    }

    CFReadStreamOpen( self->_readStream );
}

-(void)closeReadStream
{
    if ( self->_readStream )
    {
        CFReadStreamUnscheduleFromRunLoop( self->_readStream
                                          , CFRunLoopGetCurrent()
                                          , kCFRunLoopCommonModes );
        CFReadStreamClose( self->_readStream );
        CFRelease( self->_readStream );
        self->_readStream = nil;
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

    NSString* contentEncoding_ = self->_urlResponse.allHeaderFields[ @"Content-Encoding" ];
    id< JNHttpDecoder > decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: contentEncoding_ ];

    NSError* decoderError_ = nil;

    NSData* rawNsData_ = [ [ NSData alloc ] initWithBytes: buffer_ 
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
                                                                forURL: self->_params.url ];

    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ self->_cookiesStorage setCookie: cookie_ ];
    }
}

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_
{
    if ( self->_responseHandled )
    {
        return;
    }

    NSDictionary* allHeadersDict_;
    CFIndex statusCode_;

    {
        CFHTTPMessageRef response_ = (CFHTTPMessageRef)CFReadStreamCopyProperty( stream_, kCFStreamPropertyHTTPResponseHeader );

        if ( !response_ )
            return;

        allHeadersDict_ = (__bridge_transfer NSDictionary*)CFHTTPMessageCopyAllHeaderFields( response_ );
        statusCode_ = CFHTTPMessageGetResponseStatusCode( response_ );

        CFRelease( response_ );
    }

    [ self acceptCookiesForHeaders: allHeadersDict_ ];

    //JTODO test redirects (cyclic for example)
    if ( ( 301 <= statusCode_ && statusCode_ <= 303 ) || 307 == statusCode_ )
    {
        NSDebugLog( @"JConnection - creating URL..." );
        NSDebugLog( @"%@", self->_params.url );
        NSString* location_ = allHeadersDict_[ @"Location" ];
        if ( [ location_ hasPrefix: @"/" ] )
        {
            self->_params.url = [ self->_params.url URLWithLocation: location_ ];
        }
        else
        {
            self->_params.url = [ [ NSURL alloc ] initWithString: location_ ];
        }

        if ( !self->_params.url )
            self->_params.url = [ self->_params.url URLWithLocation: @"/" ];

        NSDebugLog( @"%@", self->_params.url );
        NSDebugLog( @"Done." );

        [ self start ];
    }
    else
    {
        self->_responseHandled = YES;

        if ( self.didReceiveResponseBlock )
        {
            JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];

            urlResponse_.statusCode      = statusCode_;
            urlResponse_.allHeaderFields = allHeadersDict_;
            urlResponse_.url             = self->_params.url;

            self.didReceiveResponseBlock( urlResponse_ );
            self.didReceiveResponseBlock = nil;

            self->_urlResponse = urlResponse_;
        }
    }
}

@end
