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

#import "JNStubDecoder.h"

static const char* const ZIP_QUEUE_NAME = "org.EmbeddedSources.network.gzip";
#define ZIP_QUEUE_MODE DISPATCH_QUEUE_SERIAL

@interface JFFURLConnectionContext : NSObject

@property (nonatomic) JFFURLConnectionParams *params;
@property (nonatomic, weak) JFFURLConnection *connection;

@end

@implementation JFFURLConnectionContext
@end

@interface JFFURLConnection ()

@property (nonatomic) JFFURLConnectionContext *context;
@property (nonatomic) unsigned long long downloadedBytesCount;
@property (nonatomic) unsigned long long totalBytesCount;
@property (nonatomic) dispatch_queue_t zipQueue;
@property (nonatomic) id<JNHttpDecoder> decoder;

- (void)handleResponseForReadStream:(CFReadStreamRef)stream;
- (void)handleData:(void *)buffer length:(NSUInteger)length;
- (void)handleFinish:(NSError *)error;

@end

static void readStreamCallback(CFReadStreamRef stream,
                               CFStreamEventType event,
                               void *selfContext)
{
    JFFURLConnectionContext *connectionContext = (__bridge JFFURLConnectionContext *)selfContext;
    
    if (!connectionContext.connection) {
        NSLog(@"!!!!!! ERROR !!!!!!, readStreamCallback called after freeing JFFURLConnection instance");
        return;
    }
    
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
            [connectionContext.connection handleResponseForReadStream:stream];
            
            UInt8 buffer[kJNMaxBufferSize];
            CFIndex bytesRead = CFReadStreamRead(stream, buffer, kJNMaxBufferSize);
            if (bytesRead > 0) {
                
                [connectionContext.connection handleData:buffer
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
            [connectionContext.connection handleResponseForReadStream:stream];
            
            CFStreamError error = CFReadStreamGetError(stream);
            
            JFFError *wrappedError = [[JStreamError alloc] initWithStreamError:error context:connectionContext.params];
            [connectionContext.connection handleFinish:wrappedError];
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [connectionContext.connection handleResponseForReadStream:stream];
            [connectionContext.connection handleFinish:nil];
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
    unsigned long long _downloadedBytesCount;
    unsigned long long _totalBytesCount;
    
    dispatch_queue_t _queueForCallbacks;
    
    __strong id _selfHolder;
};

@synthesize downloadedBytesCount = _downloadedBytesCount;
@synthesize totalBytesCount      = _totalBytesCount     ;

- (void)dealloc
{
    [self cancel];
}

- (instancetype)initWithURLConnectionParams:(JFFURLConnectionParams *)params
{
    self = [super init];
    
    if (self) {
        
        _context = [JFFURLConnectionContext new];
        _context.connection = self;
        _context.params     = params;
        _cookiesStorage     = _context.params.cookiesStorage?:[NSHTTPCookieStorage sharedHTTPCookieStorage];
    }
    
    return self;
}

- (NSString *)zipQueueName
{
    return [NSString stringWithFormat:@"%s-%p", ZIP_QUEUE_NAME, self];
}

- (void)start
{
    _selfHolder = self;
    
    [self startConnectionWithPostData:_context.params.httpBody
                              headers:_context.params.headers];
}

- (void)applyCookiesForHTTPRequest:(CFHTTPMessageRef)httpRequest
{
    NSArray *availableCookies = [_cookiesStorage cookiesForURL:_context.params.url];
    
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
    _queueForCallbacks = dispatch_get_current_queue();
    
    NSString *zipQueueName = [self zipQueueName];
    _zipQueue = dispatch_queue_create([zipQueueName UTF8String], ZIP_QUEUE_MODE);
    
    CFStringRef method = (__bridge CFStringRef)(_context.params.httpMethod?:@"GET");
    if (!_context.params.httpMethod && data) {
        method = (__bridge CFStringRef)@"POST";
    }
    
    CFHTTPMessageRef httpRequest = CFHTTPMessageCreateRequest(NULL,
                                                              method,
                                                              (__bridge CFURLRef)_context.params.url,
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
        (__bridge void*)(_context),
        (retain)CFRetain,
        (release)CFRelease,
        NULL};
    
    CFOptionFlags registeredEvents = kCFStreamEventHasBytesAvailable
    | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    if (CFReadStreamSetClient(_readStream, registeredEvents, readStreamCallback, &streamContext)) {
        
        CFRunLoopRef streamRunLoop = [self runLoopForReadStream];
        CFReadStreamScheduleWithRunLoop(_readStream, streamRunLoop, kCFRunLoopCommonModes);
    }
    
    Boolean openResult = CFReadStreamOpen(_readStream);
    if (!openResult) {
        
        NSLog(@"Error opening a socket");
    }
}

- (CFRunLoopRef)runLoopForReadStream
{
    CFRunLoopRef streamRunLoop = CFRunLoopGetCurrent();
    
    // @adk - there is no way to control run loops
    
//    CFRunLoopRef mainRunLoop = CFRunLoopGetMain();
//    NSParameterAssert( mainRunLoop != streamRunLoop );
    
    return streamRunLoop;
}

- (void)closeReadStream
{
    if (NULL != _readStream) {
        
        CFRunLoopRef streamRunLoop = [self runLoopForReadStream];
        
        CFReadStreamUnscheduleFromRunLoop(_readStream,
                                          streamRunLoop,
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
    [self closeStreams  ];
    [self clearCallbacks];
    
    _selfHolder = nil;
}

- (id<JNHttpDecoder>)getDecoder
{
    NSString *contentEncoding = _urlResponse.contentEncoding;
    
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
    if (!self.didReceiveDataBlock)
        return;
    
    NSData *rawNsData = [[NSData alloc] initWithBytes:buffer
                                               length:length];
    
    __weak JFFURLConnection *weakSelf = self;
    
    self.downloadedBytesCount += length;
    BOOL isDownloadCompleted = (self.totalBytesCount == self.downloadedBytesCount);
    
    dispatch_queue_t queueForCallbacks = _queueForCallbacks;
    
    dispatch_barrier_async(_zipQueue, ^void(void) {
        
        id<JNHttpDecoder> decoder = [weakSelf getDecoder];
        
        NSError *decoderError = nil;
        
        NSData *decodedData = [decoder decodeData:rawNsData
                                            error:&decoderError];
        
        BOOL finished = (nil == decodedData || isDownloadCompleted);
        
        if (finished) {
            
            NSError *decoderCloseError = nil;
            [decoder closeWithError:&decoderCloseError];
            [decoderCloseError writeErrorToNSLog];
            weakSelf.decoder = nil;
        }
        
        dispatch_sync(queueForCallbacks, ^void(void) {
            
            if (weakSelf.didReceiveDataBlock)
                weakSelf.didReceiveDataBlock(decodedData);
            
            if (finished) {
                
                NSError *error = decoderError
                ?decoderError
                :((nil == decodedData)?decoderError:nil);
                [weakSelf handleFinish:error];
            }
        });
    });
}

- (void)handleFinish:(NSError *)error
{
    __weak JFFURLConnection *weakSelf = self;
    
    dispatch_queue_t queueForCallbacks = _queueForCallbacks;
    
    dispatch_barrier_async(_zipQueue, ^void(void) {
        
        dispatch_sync(queueForCallbacks, ^void(void) {
            
            JFFDidFinishLoadingHandler didFinishLoadingBlock = weakSelf.didFinishLoadingBlock;
            
            [weakSelf cancel];
            
            if (didFinishLoadingBlock)
                didFinishLoadingBlock(error);
        });
    });
}

- (void)acceptCookiesForHeaders:(NSDictionary *)headers
{
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                              forURL:_context.params.url];
    
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
        
        allHeadersDict = (__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields(response);
        statusCode = CFHTTPMessageGetResponseStatusCode(response);
        
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
        
        DDURLBuilder *urlBuilder = [DDURLBuilder URLBuilderWithURL:_context.params.url];
        urlBuilder.shouldSkipPathPercentEncoding = YES;
        urlBuilder.path = location;
        
        _context.params.url = [urlBuilder URL];
        
        // To avoid HTTP 500
        _context.params.httpMethod = @"GET";
        _context.params.httpBody = nil;
#else
        if ([location hasPrefix:@"/"]) {
            
            _context.params.url = [_context.params.url URLWithLocation:location];
        } else {
            
            _context.params.url = [location toURL];
        }
        
        if (!_context.params.url) {
            _context.params.url = [_context.params.url URLWithLocation:@"/"];
        } 
        
        _context.params.httpMethod = @"GET";
        _context.params.httpBody = nil;
#endif
        
        NSDebugLog(@"%@", _context.params.url);
        NSDebugLog(@"Done.");
        
        [self start];//TODO start it later
    }
    else
    {
        _responseHandled = YES;
        
        JFFDidReceiveResponseHandler didReceiveResponseBlock = self.didReceiveResponseBlock;
        self.didReceiveResponseBlock = nil;
        
        if (didReceiveResponseBlock) {
            
            __strong JFFURLConnection *self_ = self;
            
            JFFURLResponse *urlResponse = [JFFURLResponse new];
            
            urlResponse.statusCode      = statusCode;
            urlResponse.allHeaderFields = allHeadersDict;
            urlResponse.url             = self_->_context.params.url;
            
            didReceiveResponseBlock(urlResponse);//here in callback connection can be cancelled
            
            //            _previousContentEncoding = _urlResponse.contentEncoding;
            self_->_decoder     = nil;
            self_->_urlResponse = urlResponse;
            
            unsigned long long tmpContentLength = [urlResponse expectedContentLength];
            if ([urlResponse hasContentLength]) {
                
                self_->_totalBytesCount = tmpContentLength;
            }
        }
    }
}

@end
