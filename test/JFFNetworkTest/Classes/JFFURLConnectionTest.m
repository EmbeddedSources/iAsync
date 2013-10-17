
@interface JFFURLConnectionTest : GHAsyncTestCase
@end

@implementation JFFURLConnectionTest

- (void)setUp
{
    [JFFURLConnection       enableInstancesCounting];
    [JFFURLConnectionParams enableInstancesCounting];
}

- (void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount = [JFFURLConnection instancesCount];
    const NSUInteger initialParamsCount = [JFFURLConnectionParams instancesCount];

    __block __weak id< JNUrlConnection > wealConnection = nil;
    
    @autoreleasepool
    {
        TestAsyncRequestBlock starterBlock = ^void(JFFSimpleBlock stopTest)
        {
            NSURL *dataUrl = [@"http://www.ietf.org/rfc/rfc4180.txt" toURL];
            
            JFFURLConnectionParams *params = [JFFURLConnectionParams new];
            params.url = dataUrl;
            JNConnectionsFactory* factory = [[JNConnectionsFactory alloc] initWithURLConnectionParams:params];
            
            NSObject< JNUrlConnection > *connection = [factory createFastConnection];
            
            NSMutableData *totalData = [NSMutableData data];
            NSData *expectedData = [NSData dataWithContentsOfURL:dataUrl];
            
            wealConnection = connection;
            connection.didReceiveResponseBlock = ^(id response)
            {
                NSLog(@"[JFFURLConnectionTest] didReceiveResponseBlock: %@ ", response);
            };
            connection.didReceiveDataBlock = ^(NSData *dataChunk)
            {
                NSLog(@"[JFFURLConnectionTest] didReceiveDataBlock: %d ", [dataChunk length]);
                [totalData appendData: dataChunk];
            };
            
            connection.didFinishLoadingBlock = ^(NSError *error)
            {
                NSLog(@"[JFFURLConnectionTest] didFinishLoadingBlock: %@ ", error);
                
                stopTest();
                GHAssertTrue([expectedData isEqualToData:totalData], @"packet mismatch" );
            };
            
            [connection start];
        };
        
        [self performAsyncRequestOnMainThreadWithBlock:starterBlock
                                              selector:_cmd
                                               timeout:61.0];
    }
    
    GHAssertTrue(wealConnection == nil, @"OK");
    
    GHAssertEquals(initialCount, [JFFURLConnection instancesCount], @"JFFURLConnection instancesCount mismatch");
    GHAssertEquals(initialParamsCount, [JFFURLConnectionParams instancesCount], @"JFFURLConnectionParams instancesCount mismatch");
}

@end
