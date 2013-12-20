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
            
            UInt8 buffer[kJNMaxBufferSize] = {0};
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
			
			
			
			
            JStreamError *wrappedError = [[JStreamError alloc] initWithStreamError:error 
                                                                           context:connectionContext.params];

            // @adk : wrap into dispatch_barrier_async() if crashes
            [connectionContext.connection handleFinish:wrappedError];
	
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [connectionContext.connection handleResponseForReadStream:stream];
	
			// @adk : wrap into dispatch_barrier_async() if crashes
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
	
	
    JFFURLResponse* _urlResponse;
    id< JNHttpDecoder > _decoder;

	
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
	// TODO : use "dependency injection" based design
	// pass "queueForCallbacks" to the constructor
    NSParameterAssert([[NSThread currentThread] isMainThread]);
    _queueForCallbacks = dispatch_get_main_queue();
    
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
										  										  
        // @adk : wrap into @synchronized if crashes. Double check NULL.
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
    [ self closeStreams    ];
    [ self clearCallbacks  ];
}

-(id<JNHttpDecoder>)getDecoder
{
    NSString* contentEncoding = self->_urlResponse.contentEncoding;

    BOOL isDecoderMissing = ( nil == self->_decoder );
    
    if ( isDecoderMissing )
    {
        JNHttpEncodingsFactory* factory = [ [ JNHttpEncodingsFactory alloc ] initWithContentLength: self->_totalBytesCount ];
        
        id< JNHttpDecoder > decoder = [ factory decoderForHeaderString: contentEncoding ];
        self->_decoder = decoder;
    }

    
    return self->_decoder;
}

-(void)handleData:( void* )buffer_
           length:( NSUInteger )length_
{
    if (!self.didReceiveDataBlock)
    {
        return;
    }
    
    __weak JFFURLConnection* weakSelf = self;
    
    id< JNHttpDecoder > decoder = [ self getDecoder ];
    NSData *rawNsData = [ [ NSData alloc ] initWithBytes: buffer_
                                                  length: length_ ];
    dispatch_queue_t zipQueue = self->_zipQueue;
    
    dispatch_barrier_async( zipQueue, ^void(void){
        NSError *decoderError = nil;
        
        NSData *decodedData = [ decoder decodeData: rawNsData
                                             error: &decoderError ];
        
        
        weakSelf.downloadedBytesCount += length_;
        BOOL isDownloadCompleted = ( weakSelf.totalBytesCount == weakSelf.downloadedBytesCount );

        BOOL finished = (nil == decodedData || isDownloadCompleted);
        
        if ( finished ){
            NSError* decoderCloseError = nil;
            [ decoder closeWithError: &decoderCloseError ];
            [ decoderCloseError writeErrorToNSLog ];
            
// @adk : ???
// maybe these blocks should be invoked with dispatch_sync()
            [ weakSelf invokeDataBlock: decodedData ];
            [ weakSelf handleFinish: decoderError ];
        }
        else
        {
            [ weakSelf invokeDataBlock: decodedData ];
        }
    } );

}

- (void)handleFinish:(NSError *)error
{
    __weak JFFURLConnection *weakSelf = self;
    
    dispatch_queue_t queueForCallbacks = _queueForCallbacks;

// wait until all unzip operations are completed
    dispatch_barrier_async(_zipQueue, ^void(void) {
        
// and notify callbacks on a proper queue
        dispatch_sync(queueForCallbacks, ^void(void) {
            
// @adk : maybe dispatch_async() is a better fit?
            JFFDidFinishLoadingHandler didFinishLoadingBlock = weakSelf.didFinishLoadingBlock;
            
            [weakSelf cancel];
            
            if (didFinishLoadingBlock)
            {
                didFinishLoadingBlock(error);
            }
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
    if (self->_responseHandled){
        return;
    }
    
    NSDictionary* allHeadersDict = nil;
    CFIndex statusCode = 0;
    
    {
        CFHTTPMessageRef response = (CFHTTPMessageRef)CFReadStreamCopyProperty(stream, kCFStreamPropertyHTTPResponseHeader);
        
        if (NULL == response)
		{
            return;	
		}
        
        allHeadersDict = (__bridge_transfer NSDictionary *)CFHTTPMessageCopyAllHeaderFields(response);
        statusCode = CFHTTPMessageGetResponseStatusCode(response);
        
		NSParameterAssert( NULL != response );
        CFRelease(response);
    }
    
    [self acceptCookiesForHeaders:allHeadersDict];
    
    //JTODO test redirects (cyclic for example)
    if ([JHttpFlagChecker isRedirectFlag:statusCode])
    {
        NSDebugLog( @"JConnection - creating URL..." );
        NSDebugLog( @"%@", self->_context.params.url );
        NSString* location_ = allHeadersDict[ @"Location" ];

#ifdef USE_DD_URL_BUILDER
        if ( ![ NSUrlLocationValidator isValidLocation: location_ ] )
        {
            NSLog( @"[!!!WARNING!!!] JConnection : path for URL is invalid. Ignoring..." );
            location_ = @"/";
        }
        
        DDURLBuilder* urlBuilder_ = [ DDURLBuilder URLBuilderWithURL: self->_context.params.url ];
        urlBuilder_.shouldSkipPathPercentEncoding = YES;
        urlBuilder_.path = location_;
        
        self->_context.params.url = [ urlBuilder_ URL ];
        
        // To avoid HTTP 500
        self->_context.params.httpMethod = @"GET";
        self->_context.params.httpBody = nil;
#else
        if ( [ location_ hasPrefix: @"/" ] )
        {
            self->_context.params.url = [ self->_context.params.url URLWithLocation: location_ ];
        }
        else
        {
            self->_context.params.url = [location_ toURL];
        }

        if ( !self->_context.params.url )
        {
            self->_context.params.url = [ self->_context.params.url URLWithLocation: @"/" ];
        }

        self->_context.params.httpMethod = @"GET";
        self->_context.params.httpBody = nil;
#endif

        NSDebugLog( @"%@", _params.url );
        NSDebugLog( @"Done." );

        [ self start ];
    }
    else
    {
        self->_responseHandled = YES;
        JFFDidReceiveResponseHandler didReceiveResponseBlock = [ self.didReceiveResponseBlock copy ];
        self.didReceiveResponseBlock = nil;

        if ( didReceiveResponseBlock )
        {
            JFFURLResponse* urlResponse = [ JFFURLResponse new ];
            
            urlResponse.statusCode      = statusCode;
            urlResponse.allHeaderFields = allHeadersDict;
            urlResponse.url             = self->_context.params.url;
         
            //here in callback connection can be cancelled
            didReceiveResponseBlock(urlResponse);
            
            self->_decoder = nil;
            self->_urlResponse = urlResponse;
            
            unsigned long long tmpContentLength = [urlResponse expectedContentLength];
            if ( [urlResponse hasContentLength] )
            {
                self->_totalBytesCount = tmpContentLength;
            }
        }
    }
}

#pragma mark -
#pragma mark Callbacks
-(void)invokeResponseBlock:( id )response
{
    JFFDidReceiveResponseHandler block = self.didReceiveResponseBlock;
    if ( nil == block )
    {
        return;
    }
    
    dispatch_async( self->_queueForCallbacks,
    ^{
        block( response );
    } );
}

-(void)invokeDataBlock:( NSData* )data
{
    JFFDidReceiveDataHandler block = self.didReceiveDataBlock;
    if ( nil == block )
    {
        return;
    }
    
    dispatch_async( self->_queueForCallbacks,
   ^{
       block( data );
   } );
}

-(void)invokeFinishBlock:( NSError* )error
{
    JFFDidFinishLoadingHandler block = self.didFinishLoadingBlock;
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
