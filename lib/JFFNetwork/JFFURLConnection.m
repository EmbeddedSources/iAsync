#import "JFFURLConnection.h"

#import "JFFURLResponse.h"

#import "JNHttpDecoder.h"
#import "JNHttpEncodingsFactory.h"
#import "JNConstants.h"

#import "JFFURLConnectionParams.h"
#import "JFFLocalCookiesStorage.h"

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
        _params = params_;
        _cookiesStorage = _params.cookiesStorage ?: [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    }

    return self;
}

-(void)start
{
    [ self startConnectionWithPostData: _params.httpBody
                               headers: _params.headers ];
}

-(void)applyCookiesForHTTPRequest:( CFHTTPMessageRef )httpRequest_
{
    NSArray* availableCookies_ = [ _cookiesStorage cookiesForURL: _params.url ];

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
    CFStringRef method_ = (__bridge  CFStringRef) (_params.httpMethod ?: @"GET");
    if ( !_params.httpMethod && data_ )
    {
        method_ = (CFStringRef) @"POST";
    }

    CFHTTPMessageRef httpRequest_ = CFHTTPMessageCreateRequest( NULL
                                                               , method_
                                                               , (__bridge CFURLRef)_params.url
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
    _readStream = CFReadStreamCreateForHTTPRequest( NULL, httpRequest_ );
    CFRelease( httpRequest_ );

    //Prefer using keep-alive packages
    Boolean keepAliveSetResult_ = CFReadStreamSetProperty( _readStream
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
    if ( CFReadStreamSetClient( _readStream, registered_events_, readStreamCallback, &streamContext_ ) )
    {
        CFReadStreamScheduleWithRunLoop( _readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes );
    }

    CFReadStreamOpen( _readStream );
}

-(void)closeReadStream
{
    if ( _readStream )
    {
        CFReadStreamUnscheduleFromRunLoop( _readStream
                                          , CFRunLoopGetCurrent()
                                          , kCFRunLoopCommonModes );
        CFReadStreamClose( _readStream );
        CFRelease( _readStream );
        _readStream = nil;
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

    NSString* contentEncoding_ = [ _urlResponse.allHeaderFields objectForKey: @"Content-Encoding" ];
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
                                                                forURL: _params.url ];

    for ( NSHTTPCookie* cookie_ in cookies_ )
    {
        [ _cookiesStorage setCookie: cookie_ ];
    }
}

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_
{
    if ( _responseHandled )
    {
        return;
    }

    CFHTTPMessageRef response_ = (CFHTTPMessageRef)CFReadStreamCopyProperty( stream_, kCFStreamPropertyHTTPResponseHeader );
    if ( response_ )
    {
        CFDictionaryRef allHeaders_ = CFHTTPMessageCopyAllHeaderFields( response_ );
        NSDictionary* allHeadersDict_ = (__bridge NSDictionary*)allHeaders_;

        [ self acceptCookiesForHeaders: allHeadersDict_ ];

        CFIndex statusCode_ = CFHTTPMessageGetResponseStatusCode( response_ );

        //JTODO test redirects (cyclic for example)
        if ( 302 == statusCode_ )
        {
            NSString* location_ = [ allHeadersDict_ objectForKey: @"Location" ];
            _params.url = [ [ NSURL alloc ] initWithScheme: _params.url.scheme
                                                      host: _params.url.host
                                                      path: location_ ];

            [ self start ];
        }
        else
        {
            _responseHandled = YES;

            if ( self.didReceiveResponseBlock )
            {
                JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];

                urlResponse_.statusCode = statusCode_;
                urlResponse_.allHeaderFields = allHeadersDict_;

                self.didReceiveResponseBlock( urlResponse_ );
                self.didReceiveResponseBlock = nil;

                _urlResponse = urlResponse_;
            }
        }

        CFRelease( allHeaders_ );
        CFRelease( response_ );
    }
}

@end
