
@interface NSConnectionTestNoArc : GHAsyncTestCase
@end

@implementation NSConnectionTestNoArc

- (void)setUp
{
    [JNNsUrlConnection enableInstancesCounting];
}

- (void)testValidDownloadCompletesCorrectly
{
    const NSUInteger initialCount = [JNNsUrlConnection instancesCount];
    id< JNUrlConnection > connection = nil;
    __block BOOL executed = NO;
    __block BOOL isDownloadSuccessfull = NO;
    __unsafe_unretained id<JNUrlConnection> unretainedConnection = connection;
    
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
            NSLog(@"[testValidDownloadCompletesCorrectly] - didReceiveResponseBlock : %@", response );
        };
        connection.didReceiveDataBlock = ^(NSData *dataChunk)
        {
            [totalData appendData:dataChunk];
        };
        
        connection.didFinishLoadingBlock = ^(NSError *error) {
            executed = YES;
            
            if (nil != error) {
                [self notify:kGHUnitWaitStatusFailure
                 forSelector:_cmd];
                return;
            }
            
            GHAssertTrue([expectedData isEqualToData:totalData], @"packet mismatch");
            isDownloadSuccessfull = YES;
            
            [self notify:kGHUnitWaitStatusSuccess
             forSelector:_cmd];
            
            [unretainedConnection cancel];
        };
        
        [connection start];
    }
    if (!executed) {
        
        [self waitForStatus:kGHUnitWaitStatusSuccess
                    timeout:61.];
    }
    [pool drain];
    
    GHAssertTrue(isDownloadSuccessfull, @"Unexpected download failure");
    
    GHAssertEquals(initialCount, [JNNsUrlConnection instancesCount], @"packet mismatch");
}

@end
