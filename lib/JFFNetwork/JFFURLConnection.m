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

@property (nonatomic) JFFURLConnectionParams *params;

- (void)handleResponseForReadStream:(CFReadStreamRef)stream;
- (void)handleData:(void *)buffer length:(NSUInteger)length;
- (void)handleFinish:(NSError *)error;

@end

static void readStreamCallback(CFReadStreamRef stream,
                               CFStreamEventType event,
                               void* selfContext)
{
    __unsafe_unretained JFFURLConnection* weakSelf = (__bridge JFFURLConnection*)selfContext;
    switch(event) {
            
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
                [weakSelf handleData:buffer
                              length:bytesRead];
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
            
            JFFError *wrappedError = [[JStreamError alloc] initWithStreamError:error context:weakSelf.params];
            [weakSelf handleFinish:wrappedError];
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
    id _cookiesStorage;
    BOOL _responseHandled;
    JFFURLResponse* _urlResponse;
};

- (void)dealloc
{
    [self cancel];
}

- (id)initWithURLConnectionParams:(JFFURLConnectionParams *)params
{
    self = [ super init ];
    
    if (self) {
        
        _params = params;
        _cookiesStorage = _params.cookiesStorage ?: [ NSHTTPCookieStorage sharedHTTPCookieStorage ];
    }
    
    return self;
}

- (void)start
{
    [self startConnectionWithPostData:_params.httpBody
                              headers:_params.headers];
}

- (void)applyCookiesForHTTPRequest:(CFHTTPMessageRef)httpRequest
{
    NSArray *availableCookies = [_cookiesStorage cookiesForURL:_params.url];
    
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        
        CFHTTPMessageSetHeaderFieldValue(httpRequest,
                                         (__bridge CFStringRef)key,
                                         (__bridge CFStringRef)value);
    }];
}

//JTODO add timeout and test
//JTODO test invalid url
//JTODO test no internet connection
- (void)startConnectionWithPostData:(NSData *)data
                            headers:(NSDictionary *)headers
{
    CFStringRef method = (__bridge CFStringRef)(_params.httpMethod?:@"GET");
    if (!_params.httpMethod && data) {
        method = (__bridge  CFStringRef)@"POST";
    }
    
    CFHTTPMessageRef httpRequest = CFHTTPMessageCreateRequest(NULL,
                                                               method,
                                                               (__bridge CFURLRef)_params.url,
                                                               kCFHTTPVersion1_1);

    [self applyCookiesForHTTPRequest:httpRequest];

    if (data) {
        
        CFHTTPMessageSetBody(httpRequest, (__bridge CFDataRef)data);
    }
    
    [headers enumerateKeysAndObjectsUsingBlock:^(id header, id headerValue, BOOL *stop) {
        
        CFHTTPMessageSetHeaderFieldValue( httpRequest
                                         , (__bridge CFStringRef)header
                                         , (__bridge CFStringRef)headerValue );
    }];
    
    [self closeReadStream];
    //   CFReadStreamCreateForStreamedHTTPRequest( CFAllocatorRef alloc,
    //                                             CFHTTPMessageRef requestHeaders,
    //                                             CFReadStreamRef	requestBody )
    _readStream = CFReadStreamCreateForHTTPRequest(NULL, httpRequest);
    CFRelease(httpRequest);

    //Prefer using keep-alive packages
    Boolean keepAliveSetResult = CFReadStreamSetProperty(_readStream,
                                                          kCFStreamPropertyHTTPAttemptPersistentConnection,
                                                          kCFBooleanTrue);
    if (FALSE == keepAliveSetResult) {
        
        NSLog(@"JFFURLConnection->start : unable to setup keep-alive packages");
    }
    
    typedef void* (*retain)(void *info);
    typedef void (*release)(void *info);
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
    
    Boolean openResult = CFReadStreamOpen(_readStream);
    if (!openResult)
    {
        NSLog( @"Error opening a socket" );
    }
}

-(void)closeReadStream
{
    if (_readStream) {
        
        CFReadStreamUnscheduleFromRunLoop(_readStream,
                                          CFRunLoopGetCurrent(),
                                          kCFRunLoopCommonModes);
        CFReadStreamClose(_readStream);
        CFRelease(_readStream);
        _readStream = nil;
    }
}

- (void)closeStreams
{
    [self closeReadStream];
}

- (void)cancel
{
    [self closeStreams];
    [self clearCallbacks];
}

- (void)handleData:(void *)buffer
            length:(NSUInteger)length
{
    if (!self.didReceiveDataBlock) {
        return;
    }
    
    NSString *contentEncoding = _urlResponse.allHeaderFields[@"Content-Encoding"];
    id< JNHttpDecoder > decoder = [ JNHttpEncodingsFactory decoderForHeaderString: contentEncoding ];
    
    NSError *decoderError;
    
    NSData *rawNsData = [[NSData alloc] initWithBytes:buffer
                                               length:length];
    
    NSData *decodedData = [decoder decodeData:rawNsData
                                        error:&decoderError];
    
    if ( nil == decodedData )
    {
        [ self handleFinish: decoderError ];
    }
    else 
    {
        self.didReceiveDataBlock(decodedData);
    }
}

- (void)handleFinish:(NSError *)error
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
    if ( _responseHandled )
    {
        return;
    }

    NSDictionary* allHeadersDict_;
    CFIndex statusCode;

    {
        CFHTTPMessageRef response_ = (CFHTTPMessageRef)CFReadStreamCopyProperty( stream_, kCFStreamPropertyHTTPResponseHeader );

        if ( !response_ )
            return;

        allHeadersDict_ = (__bridge_transfer NSDictionary*)CFHTTPMessageCopyAllHeaderFields( response_ );
        statusCode = CFHTTPMessageGetResponseStatusCode( response_ );

        CFRelease(response_);
    }

    [ self acceptCookiesForHeaders: allHeadersDict_ ];

    //JTODO test redirects (cyclic for example)
    if ([JHttpFlagChecker isRedirectFlag:statusCode]) {
        NSDebugLog( @"JConnection - creating URL..." );
        NSDebugLog( @"%@", _params.url );
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
            _params.url = [ _params.url URLWithLocation: location_ ];
        }
        else
        {
            _params.url = [location_ toURL];
        }

        if ( !_params.url )
            _params.url = [ _params.url URLWithLocation: @"/" ];

        _params.httpMethod = @"GET";
        _params.httpBody = nil;
#endif

        NSDebugLog( @"%@", _params.url );
        NSDebugLog( @"Done." );

        [ self start ];
    }
    else
    {
        _responseHandled = YES;

        if ( self.didReceiveResponseBlock )
        {
            JFFURLResponse* urlResponse_ = [JFFURLResponse new];
            
            urlResponse_.statusCode      = statusCode;
            urlResponse_.allHeaderFields = allHeadersDict_;
            urlResponse_.url             = _params.url;
            
            self.didReceiveResponseBlock( urlResponse_ );
            self.didReceiveResponseBlock = nil;
            
            _urlResponse = urlResponse_;
        }
    }
}

@end
