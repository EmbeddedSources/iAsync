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
@property (nonatomic, unsafe_unretained) dispatch_queue_t zipQueue;

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
    
    dispatch_queue_t zipQueue = [connectionContext.connection zipQueue];
    
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
            
            dispatch_barrier_async(zipQueue,
            ^{
                [connectionContext.connection handleFinish: errorObject];
            });
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [connectionContext.connection handleResponseForReadStream:stream];
            
            dispatch_barrier_async(zipQueue,
            ^{
                [connectionContext.connection handleFinish:nil];
            });
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
    id<JNHttpDecoder> _decoder;
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
        
        CFRunLoopRef streamRunLoop = [ self runLoopForReadStream ];
        
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
    if (NULL != self->_readStream) {
        
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

- (void)disposeZipQueue
{
    // @adk - using "strong" since this code may be called from "dealloc".
    // No retain cycles here
    __strong JFFURLConnection *weakSelf = self;
    
    dispatch_block_t cleanupBlock =
    ^{
        dispatch_queue_t zipQueue = [weakSelf zipQueue];
        if (NULL != zipQueue) {
            
            dispatch_release(zipQueue);
        }
        
        weakSelf.zipQueue = NULL;
    };
    
    if (nil == _queueForCallbacks)
    {
        cleanupBlock();
        return;
    }
    else
    {
        safe_dispatch_sync( self->_queueForCallbacks, cleanupBlock );
        return;
    }
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
    
    __weak JFFURLConnection* weakSelf = self;
    
    id<JNHttpDecoder> decoder = [self getDecoder];
    NSData *rawNsData = [[NSData alloc] initWithBytes:buffer
                                               length:length];
    dispatch_queue_t zipQueue = _zipQueue;
    
    dispatch_async( zipQueue,
    ^{
        NSError *decoderError = nil;
        
        NSData *decodedData = [decoder decodeData:rawNsData
                                            error:&decoderError];
        
        weakSelf.downloadedBytesCount += length;
        BOOL isDownloadCompleted = (weakSelf.totalBytesCount == weakSelf.downloadedBytesCount);
        
        if (nil == decodedData || isDownloadCompleted) {
            NSError *decoderCloseError = nil;
            [decoder closeWithError:&decoderCloseError];
            [decoderCloseError writeErrorToNSLog];
            
            weakSelf.didReceiveDataBlock(decodedData);//TODO!!! call it in main thread
            [weakSelf handleFinish:decoderError];
        }
        else {
            weakSelf invokeDataBlock:decodedData];
        }
    });
}

- (void)handleFinish:(NSError *)error
{
    [ self closeReadStream ];
    [ self invokeFinishBlock: error ];
    [ self clearCallbacks ];
    
    [ self disposeZipQueue ];
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
        
        if ( self.didReceiveResponseBlock )
        {
            JFFURLResponse* urlResponse_ = [ JFFURLResponse new ];
            
            urlResponse_.statusCode      = statusCode;
            urlResponse_.allHeaderFields = allHeadersDict_;
            urlResponse_.url             = self->_params.url;
            
            [ self invokeResponseBlock: urlResponse_ ];
            self.didReceiveResponseBlock = nil;

//            self->_previousContentEncoding = self->_urlResponse.contentEncoding;
            self->_decoder = nil;
            
            self->_urlResponse = urlResponse_;
            
            unsigned long long tmpContentLength = [ urlResponse_ expectedContentLength ];
            if ( [ urlResponse_ hasContentLength ] )
            {
                self->_totalBytesCount = tmpContentLength;
            }
        }
    }
}

#pragma mark -
#pragma mark Callbacks
- (void)invokeResponseBlock:(id)response
{
    JFFDidReceiveResponseHandler block = self.didReceiveResponseBlock;//TODO!!!
    if (nil == block) {
        return;
    }
    
    dispatch_async(self->_queueForCallbacks, ^{
        block(response);
    });
}

- (void)invokeDataBlock:(NSData *)data
{
    JFFDidReceiveDataHandler block = self.didReceiveDataBlock;//TODO!!!
    if ( nil == block )
    {
        return;
    }
    
    dispatch_async( self->_queueForCallbacks, ^{
       block( data );
    });
}

-(void)invokeFinishBlock:( NSError* )error
{
    JFFDidFinishLoadingHandler block = self.didFinishLoadingBlock;//TODO!!!
    if ( nil == block )
    {
        return;
    }
    
    
    dispatch_async( self->_queueForCallbacks,
    ^{
       block( error );
    } );
}

@end
