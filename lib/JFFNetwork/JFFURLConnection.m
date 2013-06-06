#import "JFFURLConnection.h"

#import "JFFURLResponse.h"

#import "JNHttpDecoder.h"
#import "JNHttpEncodingsFactory.h"
#import "JNConstants.h"

#import "JFFURLConnectionParams.h"
#import "JFFLocalCookiesStorage.h"

#import "NSURL+URLWithLocation.h"

#import "JHttpError.h"
#import "JStreamError.h"
#import "JHttpFlagChecker.h"

//#define SHOW_DEBUG_LOGS
#import <JFFLibrary/JDebugLog.h>

//#define USE_DD_URL_BUILDER

#ifdef USE_DD_URL_BUILDER
    #import <DDURLBuilder/DDURLBuilder.h>
    #import "NSUrlLocationValidator.h"
#endif

@interface JFFURLConnection ()

-(void)handleResponseForReadStream:( CFReadStreamRef )stream_;
-(void)handleData:( void* )buffer_ length:( NSUInteger )length_;
-(void)handleFinish:( NSError* )error;

@end

static void readStreamCallback(CFReadStreamRef stream,
                               CFStreamEventType event_,
                               void* selfContext_ )
{
    __unsafe_unretained JFFURLConnection* weakSelf = (__bridge JFFURLConnection*)selfContext_;
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
            [ weakSelf handleResponseForReadStream: stream ];

            UInt8 buffer[ kJNMaxBufferSize ];
            CFIndex bytesRead = CFReadStreamRead( stream, buffer, kJNMaxBufferSize );
            if ( bytesRead > 0 )
            {
                [ weakSelf handleData: buffer
                               length: (NSUInteger)bytesRead ];
            }
            break;
        }
        case kCFStreamEventCanAcceptBytes:
        {
            break;
        }
        case kCFStreamEventErrorOccurred:
        {
            [weakSelf handleResponseForReadStream:stream];
            
            CFStreamError error = CFReadStreamGetError(stream);
            JStreamError* errorObject = [ [ JStreamError alloc ] initWithStreamError: error ];
            
            [weakSelf handleFinish: errorObject];
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [ weakSelf handleResponseForReadStream: stream ];
            
            [ weakSelf handleFinish: nil ];
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

//    NSString* _previousContentEncoding;
    id< JNHttpDecoder > _decoder;
    unsigned long long _downloadedBytesCount;
    unsigned long long _totalBytesCount;
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
    [ self startConnectionWithPostData:_params.httpBody
                               headers:_params.headers ];
}

-(void)applyCookiesForHTTPRequest:( CFHTTPMessageRef )httpRequest_
{
    NSArray *availableCookies_ = [ _cookiesStorage cookiesForURL: _params.url ];

    NSDictionary *headers = [ NSHTTPCookie requestHeaderFieldsWithCookies: availableCookies_ ];

    [headers enumerateKeysAndObjectsUsingBlock: ^( id key_, id value_, BOOL *stop )
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
    CFStringRef method = (__bridge CFStringRef)(self->_params.httpMethod?:@"GET");
    if ( !self->_params.httpMethod && data_ )
    {
        method = (__bridge  CFStringRef)@"POST";
    }
    
    CFHTTPMessageRef httpRequest_ = CFHTTPMessageCreateRequest(NULL,
                                                               method,
                                                               (__bridge CFURLRef)_params.url,
                                                               kCFHTTPVersion1_1);

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
    CFStreamClientContext streamContext_ =
    {
        0
        , (__bridge void*)(self)
        , (retain)CFRetain
        , (release)CFRelease
        , NULL
    };

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

-(id<JNHttpDecoder>)getDecoder
{
    NSString* contentEncoding = self->_urlResponse.contentEncoding;
//    NSString* previousEncoding = self->_previousContentEncoding;


    BOOL isDecoderMissing = ( nil == self->_decoder );
    
    if ( isDecoderMissing )
    {
        JNHttpEncodingsFactory* factory = [ [ JNHttpEncodingsFactory alloc ] initWithContentLength: self->_totalBytesCount ];
        
        id< JNHttpDecoder > decoder = [ factory decoderForHeaderString: contentEncoding ];
        self->_decoder = decoder;
    }

//    [ @"http://ws-alr1.dk.sitecore.net:66/sitecore/shell/ClientBin/Dashboard/Integration.ashx?action=loadPreFilterParams" isEqualToString: (NSString*)[ ((NSURL*)[ self->_urlResponse url ]) absoluteString ] ]
    
    return self->_decoder;
}

-(void)handleData:( void* )buffer_
           length:( NSUInteger )length_
{
    if (!self.didReceiveDataBlock)
    {
        return;
    }
    
    id< JNHttpDecoder > decoder = [ self getDecoder ];
    
    NSError *decoderError = nil;
    NSData *rawNsData = [ [ NSData alloc ] initWithBytes: buffer_
                                                   length: length_ ];
    
    NSData *decodedData = [ decoder decodeData: rawNsData
                                         error: &decoderError ];
    
    // @adk - maybe we should use [decodedData length]
    self->_downloadedBytesCount += length_;
    BOOL isDownloadCompleted = ( self->_totalBytesCount == self->_downloadedBytesCount );
    
    if ( nil == decodedData || isDownloadCompleted )
    {
        NSError* decoderCloseError = nil;
        [ decoder closeWithError: &decoderCloseError ];
        [ decoderCloseError writeErrorToNSLog ];
        
        
        self.didReceiveDataBlock(decodedData);
        [ self handleFinish: decoderError ];
    }
    else 
    {
        self.didReceiveDataBlock(decodedData);
    }
}

-(void)handleFinish:( NSError* )error
{
    [ self closeReadStream ];

    if ( self.didFinishLoadingBlock )
    {
        self.didFinishLoadingBlock( error );
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
    if ( self->_responseHandled )
    {
        return;
    }

    NSDictionary* allHeadersDict_;
    CFIndex statusCode;

    {
        CFHTTPMessageRef response_ = (CFHTTPMessageRef)CFReadStreamCopyProperty( stream_, kCFStreamPropertyHTTPResponseHeader );

        if ( !response_ )
        {
            return;
        }

        allHeadersDict_ = (__bridge_transfer NSDictionary*)CFHTTPMessageCopyAllHeaderFields( response_ );
        statusCode = CFHTTPMessageGetResponseStatusCode( response_ );

        CFRelease(response_);
    }

    [ self acceptCookiesForHeaders: allHeadersDict_ ];

    //JTODO test redirects (cyclic for example)
    if ([JHttpFlagChecker isRedirectFlag:statusCode])
    {
        NSDebugLog( @"JConnection - creating URL..." );
        NSDebugLog( @"%@", self->_params.url );
        NSString* location_ = allHeadersDict_[ @"Location" ];

#ifdef USE_DD_URL_BUILDER
        if ( ![ NSUrlLocationValidator isValidLocation: location_ ] )
        {
            NSLog( @"[!!!WARNING!!!] JConnection : path for URL is invalid. Ignoring..." );
            location_ = @"/";
        }
        
        DDURLBuilder* urlBuilder_ = [ DDURLBuilder URLBuilderWithURL: self->_params.url ];
        urlBuilder_.shouldSkipPathPercentEncoding = YES;
        urlBuilder_.path = location_;
        
        self->_params.url = [ urlBuilder_ URL ];
        
        // To avoid HTTP 500
        self->_params.httpMethod = @"GET";
        self->_params.httpBody = nil;
#else
        if ( [ location_ hasPrefix: @"/" ] )
        {
            self->_params.url = [ self->_params.url URLWithLocation: location_ ];
        }
        else
        {
            self->_params.url = [location_ toURL];
        }

        if ( !self->_params.url )
        {
            self->_params.url = [ self->_params.url URLWithLocation: @"/" ];
        }

        self->_params.httpMethod = @"GET";
        self->_params.httpBody = nil;
#endif

        NSDebugLog( @"%@", _params.url );
        NSDebugLog( @"Done." );

        [ self start ];
    }
    else
    {
        self->_responseHandled = YES;

        if ( self.didReceiveResponseBlock )
        {
            JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];
            
            urlResponse_.statusCode      = statusCode;
            urlResponse_.allHeaderFields = allHeadersDict_;
            urlResponse_.url             = self->_params.url;
            
            self.didReceiveResponseBlock( urlResponse_ );
            self.didReceiveResponseBlock = nil;

//            self->_previousContentEncoding = self->_urlResponse.contentEncoding;
            self->_decoder = nil;
            
            self->_urlResponse = urlResponse_;
            
            self->_totalBytesCount = urlResponse_.expectedContentLength;
        }
    }
}

@end
