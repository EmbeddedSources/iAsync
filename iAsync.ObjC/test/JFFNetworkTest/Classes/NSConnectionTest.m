
@interface NSConnectionTest : GHAsyncTestCase
@end

@implementation NSConnectionTest

- (void)setUp
{
    [JNNsUrlConnection enableInstancesCounting];
}

- (void)testValidDownloadCompletesLocalFileCorrectly
{
    const NSUInteger initialCount = [JNNsUrlConnection instancesCount];
    
    @autoreleasepool
    {
        [self prepare];
        
        NSURL *dataUrl = [[JNTestBundleManager decodersDataBundle] URLForResource:@"1"
                                                                    withExtension:@"txt"];
        
        JFFURLConnectionParams *params = [JFFURLConnectionParams new];
        params.url = dataUrl;
        JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
        
        id< JNUrlConnection > connection = [factory createStandardConnection];
        
        NSMutableData* totalData_ = [ NSMutableData new ];
        NSData* expectedData_ = [ [ NSData alloc ] initWithContentsOfURL:dataUrl];
        
        connection.didReceiveResponseBlock = ^( id response_ )
        {
            //IDLE
        };
        connection.didReceiveDataBlock = ^( NSData* dataChunk_ )
        {
            [ totalData_ appendData: dataChunk_ ];
        };

        connection.didFinishLoadingBlock = ^(NSError *error)
        {
            if (nil != error) {
                
                [self notify:kGHUnitWaitStatusFailure
                 forSelector:_cmd];
                return;
            }
            
            GHAssertTrue([expectedData_ isEqualToData:totalData_], @"packet mismatch");
            [self notify:kGHUnitWaitStatusSuccess
             forSelector:_cmd];
        };
        
        [connection start];
        [self waitForStatus:kGHUnitWaitStatusSuccess
                    timeout:61.];
    }
    
    GHAssertEquals(initialCount, [JNNsUrlConnection instancesCount], @"packet mismatch");
}

- (void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount = [JNNsUrlConnection instancesCount];
    __block BOOL dataReceived_ = NO;
    __block BOOL isDownloadExecuted = NO;
    
    @autoreleasepool
    {
        TestAsyncRequestBlock starterBlock = ^void(JFFSimpleBlock stopTest)
        {
            NSURL *dataUrl = [@"http://www.ietf.org/rfc/rfc4180.txt" toURL];
            
            JFFURLConnectionParams *params = [JFFURLConnectionParams new];
            params.url = dataUrl;
            JNConnectionsFactory *factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
            
            id< JNUrlConnection > connection = [factory createStandardConnection];
            
            connection.didReceiveResponseBlock = ^(id response) {
                NSLog( @"[testValidDownloadCompletesCorrectly] - didReceiveResponseBlock : %@", response );
            };
            
            connection.didReceiveDataBlock = ^(NSData *dataChunk) {
                dataReceived_ = YES;
            };
            
            connection.didFinishLoadingBlock = ^(NSError *error) {
                
                NSLog( @"[testValidDownloadCompletesCorrectly] - connectionDidFinishLoading" );
                isDownloadExecuted = YES;
                
                stopTest();                
            };
            
            [connection start];
        };
        
        [self performAsyncRequestOnMainThreadWithBlock:starterBlock
                                              selector:_cmd
                                               timeout:61.0];
    }
    
    GHAssertTrue(dataReceived_, @"packet mismatch" );
    
    GHAssertEquals(initialCount, [JNNsUrlConnection instancesCount], @"packet mismatch");
}

- (void)RtestInValidDownloadCompletesWithError
{
    [self prepare];
    
    NSURL *dataUrl = [NSURL URLWithString:@"http://kdjsfhjkfhsdfjkdhfjkds.com"];
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url = dataUrl;
    JNConnectionsFactory *factory = [ [ JNConnectionsFactory alloc ] initWithURLConnectionParams:params];
    
    id< JNUrlConnection > connection = [ factory createStandardConnection ];
    
    connection.didReceiveResponseBlock = ^( id response_ )
    {
        //IDLE
    };
    connection.didReceiveDataBlock = ^( NSData* data_chunk_ )
    {
    };
    connection.didFinishLoadingBlock = ^( NSError* error_ )
    {
        if ( nil != error_ )
        {
            [ self notify: kGHUnitWaitStatusSuccess 
              forSelector: _cmd ];
            return;
        }

        [ self notify: kGHUnitWaitStatusFailure
          forSelector: _cmd ];
    };

    [connection start];
    [self waitForStatus:kGHUnitWaitStatusSuccess
                timeout:61.];
}

@end
