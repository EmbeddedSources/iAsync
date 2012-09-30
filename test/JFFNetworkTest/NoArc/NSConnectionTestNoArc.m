
@interface NSConnectionTestNoArc : GHAsyncTestCase
@end

@implementation NSConnectionTestNoArc

-(void)setUp
{
    [JNNsUrlConnection enableInstancesCounting];
}

- (void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount = [JNNsUrlConnection instancesCount];
    id< JNUrlConnection > connection;
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [self prepare];
    {
        NSURL *dataUrl = [[JNTestBundleManager decodersDataBundle] URLForResource:@"1"
                                                                    withExtension:@"txt"];
        
        JFFURLConnectionParams *params = [[JFFURLConnectionParams new] autorelease];
        params.url = dataUrl;
        JNConnectionsFactory *factory = [[[JNConnectionsFactory alloc] initWithURLConnectionParams:params] autorelease];
        
        connection = [factory createStandardConnection];
        
        NSMutableData *totalData = [NSMutableData data];
        NSData *expectedData = [NSData dataWithContentsOfURL:dataUrl];
        
        connection.didReceiveResponseBlock = ^(id response)
        {
            //IDLE
        };
        connection.didReceiveDataBlock = ^(NSData *dataChunk)
        {
            [totalData appendData:dataChunk];
        };
        
        connection.didFinishLoadingBlock = ^(NSError *error) {
            if (nil != error) {
                [self notify:kGHUnitWaitStatusFailure
                 forSelector:_cmd];
                return;
            }
            
            GHAssertTrue([expectedData isEqualToData:totalData], @"packet mismatch");
            [self notify:kGHUnitWaitStatusSuccess
             forSelector:_cmd];
        };
        
        [connection start];
    }
    [self waitForStatus:kGHUnitWaitStatusSuccess
                timeout:61.];
    [pool drain];
    
    NSUInteger currentCount = [JNNsUrlConnection instancesCount];
    GHAssertTrue(initialCount == currentCount, @"packet mismatch");
}

@end
