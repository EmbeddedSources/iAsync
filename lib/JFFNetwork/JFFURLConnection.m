#import "JFFURLConnection.h"
#import "JNAbstractConnection+Constructor.h"

#import "JFFURLResponse.h"

#import "JNHttpDecoder.h"
#import "JNHttpEncodingsFactory.h"
#import "JNConstants.h"

#import <JFFUtils/JFFError.h>

@interface JFFURLConnection ()

//JTODO move to ARC and remove inner properties
@property ( nonatomic, retain ) NSData* httpBody;
@property ( nonatomic, retain ) NSString* httpMethod;
@property ( nonatomic, retain ) NSDictionary* headers;

@property ( nonatomic, assign ) BOOL responseHandled;
@property ( nonatomic, retain ) __attribute__((NSObject)) CFReadStreamRef readStream;
@property ( nonatomic, retain ) NSURL* url;

@property ( nonatomic, retain ) JFFURLResponse* urlResponse;

-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_;

-(void)cancel;

-(void)closeReadStream;

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_;
-(void)handleData:( void* )buffer_ length:( NSUInteger )length_;
-(void)handleFinish:( NSError* )error_;

@end

static void readStreamCallback( CFReadStreamRef stream_, CFStreamEventType event_, void* selfContext_ )
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

@synthesize httpBody   = _postData;
@synthesize httpMethod = _httpMethod;
@synthesize headers    = _headers;

@synthesize url = _url;
@synthesize responseHandled = _responseHandled;

@synthesize urlResponse = _urlResponse;
@synthesize readStream  = _readStream;

-(void)dealloc
{
    [ self cancel ];

    self.httpBody    = nil;
    self.httpMethod  = nil;
    self.headers     = nil;
    self.url         = nil;
    self.urlResponse = nil;

    [ super dealloc ];
}

-(id)initWithURL:( NSURL* )url_
        httpBody:( NSData* )data_
      httpMethod:( NSString* )httpMethod_
         headers:( NSDictionary* )headers_
{
    self = [ super privateInit ];

    if ( self )
    {
        self.url        = url_;
        self.httpBody   = data_;
        self.httpMethod = httpMethod_;
        self.headers    = headers_;
    }

    return self;
}

-(void)start
{
    [ self startConnectionWithPostData: self.httpBody headers: self.headers ];
}

+(id)connectionWithURL:( NSURL* )url_
              httpBody:( NSData* )data_
            httpMethod:( NSString* )httpMethod_
           contentType:( NSString* )content_type_
{
    NSDictionary* headers_ = [ NSDictionary dictionaryWithObjectsAndKeys: 
                              content_type_, @"Content-Type"
                              , @"keep-alive", @"Connection"
                              , nil ];

    return [ self connectionWithURL: url_
                           httpBody: data_
                         httpMethod: httpMethod_
                            headers: headers_ ];
}

+(id)connectionWithURL:( NSURL* )url_
              httpBody:( NSData* )data_
            httpMethod:( NSString* )httpMethod_
               headers:( NSDictionary* )headers_
{
    return [ [ [ self alloc ] initWithURL: url_
                                 httpBody: data_
                               httpMethod: httpMethod_
                                  headers: headers_ ] autorelease ];
}

-(void)applyCookiesForHTTPRequest:( CFHTTPMessageRef )httpRequest_
{
    NSArray* availableCookies_ = [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] cookiesForURL: self.url ];

    NSDictionary* headers_ = [ NSHTTPCookie requestHeaderFieldsWithCookies: availableCookies_ ];

    for ( NSString* key_ in headers_ )
    {
        NSString* value_ = [ headers_ objectForKey: key_ ];
        CFHTTPMessageSetHeaderFieldValue ( httpRequest_, (CFStringRef)key_, (CFStringRef)value_ );
    }
}

//JTODO add timeout
//JTODO test invalid url
//JTODO test no internet connection
-(void)startConnectionWithPostData:( NSData* )data_
                           headers:( NSDictionary* )headers_
{
    CFStringRef method_ = (CFStringRef) (self.httpMethod ?: @"GET");
    if ( !self.httpMethod && data_ )
    {
        method_ = (CFStringRef) @"POST";
    }

    CFHTTPMessageRef httpRequest_ = CFHTTPMessageCreateRequest( NULL
                                                               , method_
                                                               , (CFURLRef)self.url
                                                               , kCFHTTPVersion1_1 );

    [ self applyCookiesForHTTPRequest: httpRequest_ ];

    if ( data_ )
    {
        CFHTTPMessageSetBody ( httpRequest_, (CFDataRef)data_ );
    }

    for ( NSString* header_ in headers_ )
    {
        CFHTTPMessageSetHeaderFieldValue( httpRequest_
                                         ,(CFStringRef)header_
                                         ,(CFStringRef)[ headers_ objectForKey: header_ ] );
    }

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
        CFReadStreamUnscheduleFromRunLoop( _readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
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

    NSString* content_encoding_ = [ self.urlResponse.allHeaderFields objectForKey: @"Content-Encoding" ];
    id< JNHttpDecoder > decoder_ = [ JNHttpEncodingsFactory decoderForHeaderString: content_encoding_ ];

    NSError* decoder_error_ = nil;

    NSData* raw_ns_data_ = [ NSData dataWithBytes: buffer_ 
                                           length: length_ ];

    NSData* decoded_data_ = [ decoder_ decodeData: raw_ns_data_ 
                                            error: &decoder_error_ ];

    if ( nil == decoded_data_ )
    {
        [ self handleFinish: decoder_error_ ];
    }
    else 
    {
        self.didReceiveDataBlock( decoded_data_ );
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
    NSArray* cookies_ = [ NSHTTPCookie cookiesWithResponseHeaderFields: headers_ forURL: self.url ];
    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ [ NSHTTPCookieStorage sharedHTTPCookieStorage ] setCookie: cookie_ ];
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
            CFIndex error_code_ = CFHTTPMessageGetResponseStatusCode( response_ );

            JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];
            urlResponse_.statusCode = error_code_;

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
