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

#import <JFFUtils/JFFUtils.h>

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
    __unsafe_unretained JFFURLConnection *weakSelf = (__bridge JFFURLConnection*)selfContext;
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
            [weakSelf handleResponseForReadStream:stream];

            UInt8 buffer[ kJNMaxBufferSize ];
            CFIndex bytesRead = CFReadStreamRead(stream, buffer, kJNMaxBufferSize);
            if ( bytesRead > 0 ) {
                
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
            [weakSelf handleResponseForReadStream:stream];
            
            [weakSelf handleFinish:nil];
            break;
        }
    }
}

@implementation JFFURLConnection
{
    CFReadStreamRef _readStream;
    id _cookiesStorage;
    BOOL _responseHandled;
    JFFURLResponse *_urlResponse;

//    NSString* _previousContentEncoding;
    id< JNHttpDecoder > _decoder;
    unsigned long long _downloadedBytesCount;
    unsigned long long _totalBytesCount;
};

- (void)dealloc
{
    [self cancel];
}

- (instancetype)initWithURLConnectionParams:(JFFURLConnectionParams *)params
{
    self = [super init];
    
    if (self) {
        
        _params = params;
        _cookiesStorage = _params.cookiesStorage?:[NSHTTPCookieStorage sharedHTTPCookieStorage];
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
        method = (__bridge CFStringRef)@"POST";
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
        
        CFHTTPMessageSetHeaderFieldValue(httpRequest,
                                         (__bridge CFStringRef)header,
                                         (__bridge CFStringRef)headerValue);
    }];
    
    [self closeReadStream];
    //   CFReadStreamCreateForStreamedHTTPRequest( CFAllocatorRef alloc,
    //                                             CFHTTPMessageRef requestHeaders,
    //                                             CFReadStreamRef  requestBody )
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
    CFStreamClientContext streamContext = {
        0,
        (__bridge void*)(self),
        (retain)CFRetain,
        (release)CFRelease,
        NULL};
    
    CFOptionFlags registeredEvents = kCFStreamEventHasBytesAvailable
        | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    if (CFReadStreamSetClient(_readStream, registeredEvents, readStreamCallback, &streamContext)) {
        
        CFReadStreamScheduleWithRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    
    Boolean openResult = CFReadStreamOpen(_readStream);
    if (!openResult) {
        
        NSLog(@"Error opening a socket");
    }
}

- (void)closeReadStream
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

-(id<JNHttpDecoder>)getDecoder
{
    NSString *contentEncoding = _urlResponse.contentEncoding;
//    NSString *previousEncoding = _previousContentEncoding;
    
    BOOL isDecoderMissing = (nil == _decoder);
    
    if (isDecoderMissing) {
        JNHttpEncodingsFactory *factory = [[JNHttpEncodingsFactory alloc] initWithContentLength:_totalBytesCount];
        
        id<JNHttpDecoder> decoder = [factory decoderForHeaderString:contentEncoding];
        _decoder = decoder;
    }
    
    return _decoder;
}

- (void)handleData:(void *)buffer
            length:(NSUInteger)length
{
    if (!self.didReceiveDataBlock) {
        return;
    }
    
    id< JNHttpDecoder > decoder = [self getDecoder];
    
    NSError *decoderError = nil;
    NSData *rawNsData = [[NSData alloc] initWithBytes:buffer
                                               length:length];
    
    NSData *decodedData = [decoder decodeData:rawNsData
                                        error:&decoderError];
    
    // @adk - maybe we should use [decodedData length]
    _downloadedBytesCount += length;
    BOOL isDownloadCompleted = (_totalBytesCount == _downloadedBytesCount);
    
    if (nil == decodedData || isDownloadCompleted) {
        NSError *decoderCloseError = nil;
        [decoder closeWithError:&decoderCloseError];
        [decoderCloseError writeErrorToNSLog];
        
        self.didReceiveDataBlock(decodedData);
        [self handleFinish:decoderError];
    }
    else {
        self.didReceiveDataBlock(decodedData);
    }
}

- (void)handleFinish:(NSError *)error
{
    [self closeReadStream];
    
    if (self.didFinishLoadingBlock) {
        
        self.didFinishLoadingBlock(error);
    }
    [self clearCallbacks];
}

- (void)acceptCookiesForHeaders:(NSDictionary *)headers
{
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                              forURL:_params.url];
    
    for (NSHTTPCookie *cookie in cookies) {
        
        [_cookiesStorage setCookie:cookie];
    }
}

- (void)handleResponseForReadStream:(CFReadStreamRef)stream
{
    if (_responseHandled) {
        return;
    }
    
    NSDictionary* allHeadersDict;
    CFIndex statusCode;
    
    {
        CFHTTPMessageRef response = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
        
        if (!response)
            return;
        
        allHeadersDict = (__bridge_transfer NSDictionary*)CFHTTPMessageCopyAllHeaderFields( response );
        statusCode = CFHTTPMessageGetResponseStatusCode( response );
        
        CFRelease(response);
    }
    
    [self acceptCookiesForHeaders:allHeadersDict];
    
    //JTODO test redirects (cyclic for example)
    if ([JHttpFlagChecker isRedirectFlag:statusCode]) {
        NSDebugLog(@"JConnection - creating URL...");
        NSDebugLog(@"%@", _params.url);
        NSString *location = allHeadersDict[@"Location"];
        
#ifdef USE_DD_URL_BUILDER
        if (![ NSUrlLocationValidator isValidLocation:location]) {
            
            NSLog(@"[!!!WARNING!!!] JConnection : path for URL is invalid. Ignoring...");
            location = @"/";
        }
        
        DDURLBuilder *urlBuilder = [DDURLBuilder URLBuilderWithURL:_params.url];
        urlBuilder.shouldSkipPathPercentEncoding = YES;
        urlBuilder.path = location;
        
        _params.url = [urlBuilder URL];
        
        // To avoid HTTP 500
        _params.httpMethod = @"GET";
        _params.httpBody = nil;
#else
        if ([location hasPrefix:@"/"]) {
            
            _params.url = [_params.url URLWithLocation:location];
        } else {
            
            _params.url = [location toURL];
        }
        
        _params.httpMethod = @"GET";
        _params.httpBody = nil;
#endif
        
        NSDebugLog(@"%@", _params.url);
        NSDebugLog(@"Done.");
        
        [self start];//TODO start it later
    }
    else
    {
        _responseHandled = YES;

        if (self.didReceiveResponseBlock) {
            
            JFFURLResponse *urlResponse = [JFFURLResponse new];
            
            urlResponse.statusCode      = statusCode;
            urlResponse.allHeaderFields = allHeadersDict;
            urlResponse.url             = _params.url;
            
            self.didReceiveResponseBlock(urlResponse);
            self.didReceiveResponseBlock = nil;
            
//            _previousContentEncoding = _urlResponse.contentEncoding;
            _decoder = nil;
            
            _urlResponse = urlResponse;
            
            _totalBytesCount = urlResponse.expectedContentLength;
        }
    }
}

@end
