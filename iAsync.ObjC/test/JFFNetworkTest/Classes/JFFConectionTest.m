@interface JFFConectionTest : GHAsyncTestCase
@end

@implementation JFFConectionTest

//TODO test leaks

- (void)setUp
{
    [JFFURLConnection enableInstancesCounting];//JTODO test
}

//http://jigsaw.w3.org/HTTP/negbad
- (void)testHttp406NotAcceptableCode
{
    NSUInteger initialInstancesCount = [JFFURLConnection instancesCount];
    
    @autoreleasepool {
        __block NSError *didFinishLoadingBlockError;
        
        NSURL *dataUrl = [@"http://jigsaw.w3.org/HTTP/negbad" toURL];
        NSData *expectedData = [[NSData alloc] initWithContentsOfURL:dataUrl];
        
        __block NSMutableData *totalData;
        
        void (^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishTest) {
            
            JFFAsyncOperationProgressCallback progress = ^(NSData *dataChunk) {
                if (!totalData)
                    totalData = [NSMutableData new];
                [totalData appendData:dataChunk];
            };
            
            JFFDidFinishAsyncOperationCallback finish = ^(id result, NSError *error) {
                
                didFinishLoadingBlockError = error;
                finishTest();
            };
            
            JFFAsyncOperation loader = liveChunkedURLResponseLoader(dataUrl, nil, nil);
            loader(progress, nil, finish);
        };
        
        [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                              selector:_cmd
                                               timeout:61.];
        
        GHAssertTrue([didFinishLoadingBlockError isKindOfClass:[JHttpError class]], @"Expected error with class - %@", [JHttpError class] );
        GHAssertNil(expectedData, @"packet mismatch");
        GHAssertNil(totalData   , @"packet mismatch");
    }
    
    GHAssertEquals(initialInstancesCount, [JFFURLConnection instancesCount], @"packet mismatch");
}

//http://jigsaw.w3.org/HTTP/300/Go_301
- (void)testRedirectOnHttp301Code
{
    NSUInteger initialInstancesCount = [JFFURLConnection instancesCount];
    
    @autoreleasepool {
    
        __block NSError *didFinishLoadingBlockError;
        
        NSURL *dataUrl = [@"http://jigsaw.w3.org/HTTP/300/301.html" toURL];
        NSData *expectedData = [[NSData alloc] initWithContentsOfURL:dataUrl];
        
        NSMutableData *totalData = [NSMutableData new];
        
        void (^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishTest) {
            
            JFFURLConnectionParams *params = [JFFURLConnectionParams new];
            params.url = dataUrl;
            
            JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
            
            id<JNUrlConnection> connection = [factory createFastConnection];
            
            connection.didReceiveResponseBlock = ^(id response)
            {
                //IDLE
            };
            connection.didReceiveDataBlock = ^(NSData *dataChunk)
            {
                [totalData appendData:dataChunk];
            };
            
            connection.didFinishLoadingBlock = ^(NSError *error)
            {
                didFinishLoadingBlockError = error;
                finishTest();
            };
            
            [connection start];
        };
        
        [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                              selector:_cmd
                                               timeout:61.];
        
        GHAssertNil(didFinishLoadingBlockError, @"Unexpected error - %@", didFinishLoadingBlockError);
        GHAssertTrue([expectedData length] == [totalData length], @"packet mismatch" );
    }
    
    GHAssertEquals(initialInstancesCount, [JFFURLConnection instancesCount], @"packet mismatch");
}

// http://jigsaw.w3.org/HTTP/300/Overview.html
- (void)testRedirectOnHttp302Code
{
    NSUInteger initialInstancesCount = [JFFURLConnection instancesCount];
    
    __block NSError *didFinishLoadingBlockError;
    
    NSURL* dataUrl = [@"http://jigsaw.w3.org/HTTP/300/302.html" toURL];
    NSData* expectedData = [[NSData alloc] initWithContentsOfURL:dataUrl];

    NSMutableData* totalData = [NSMutableData new];

    void (^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishTest) {
        
        JFFURLConnectionParams *params = [JFFURLConnectionParams new];
        params.url = dataUrl;
        JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
        
        id<JNUrlConnection> connection = [factory createFastConnection];
        
        connection.didReceiveResponseBlock = ^(id response)
        {
            //IDLE
        };
        connection.didReceiveDataBlock = ^(NSData *dataChunk)
        {
            [totalData appendData:dataChunk];
        };
        
        connection.didFinishLoadingBlock = ^(NSError *error)
        {
            didFinishLoadingBlockError = error;
            finishTest();
        };
        
        [connection start];
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd
                                           timeout:61.];
    
    GHAssertNil(didFinishLoadingBlockError, @"Unexpected error - %@", didFinishLoadingBlockError );
    GHAssertTrue([expectedData length] == [totalData length], @"packet mismatch" );
    
    GHAssertEquals(initialInstancesCount, [JFFURLConnection instancesCount], @"packet mismatch");
}

//JTODO add file - http://10.28.9.57:9000/about/
- (void)RtestValidDownloadCompletesCorrectly
{
    [self prepare];
    
    NSURL *dataUrl = [ NSURL URLWithString: @"http://10.28.9.57:9000/about/" ];
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url = dataUrl;
    JNConnectionsFactory* factory_ = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams: params ];
   
    id< JNUrlConnection > connection_ = [ factory_ createFastConnection ];
    NSMutableData* totalData_ = [ NSMutableData new ];
    NSData* expectedData_ = [ NSData dataWithContentsOfURL: dataUrl ];

    connection_.didReceiveResponseBlock = ^( id response_ )
    {
        //IDLE
    };
    connection_.didReceiveDataBlock = ^( NSData* dataChunk_ )
    {
        [ totalData_ appendData: dataChunk_ ];
    };

    connection_.didFinishLoadingBlock = ^( NSError* error_ )
    {
        GHAssertNil( error_, @"Unexpected error - %@", error_ );    
        GHAssertTrue( [ expectedData_ length ] == [ totalData_ length ], @"packet mismatch" );
        [ self notify: kGHUnitWaitStatusSuccess 
          forSelector: _cmd ];
    };
  
    [ connection_ start ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: 61. ];
}

//now http://kdjsfhjkfhsdfjkdhfjkds.com redirected
- (void)RtestInValidDownloadCompletesWithError
{
    [self prepare];
    
    NSURL *dataUrl = [ NSURL URLWithString: @"http://kdjsfhjkfhsdfjkdhfjkds.com" ];
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url = dataUrl;
    JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
    
    id< JNUrlConnection > connection_ = [factory createFastConnection];

    connection_.didReceiveResponseBlock = ^(id response)
    {
        //IDLE
    };
    connection_.didReceiveDataBlock = ^(NSData *dataChunk)
    {
    };
    connection_.didFinishLoadingBlock = ^(NSError *error)
    {
        if (nil != error)
        {
            [self notify:kGHUnitWaitStatusSuccess
             forSelector:_cmd];
            return;
        }
        
        [self notify:kGHUnitWaitStatusFailure
         forSelector:_cmd];
    };
    
    [connection_ start];
    [self waitForStatus:kGHUnitWaitStatusSuccess
                timeout:61.];
}

@end
