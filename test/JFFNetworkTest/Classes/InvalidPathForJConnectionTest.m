#import "BadHeadersMockNetwork.h"

@interface InvalidPathForJConnectionTest : GHAsyncTestCase< NSURLConnectionDelegate >
@end

@implementation InvalidPathForJConnectionTest

- (void)setUp
{
    [NSURLProtocol registerClass:[BadHeadersMockNetwork class]];
    [JNNsUrlConnection enableInstancesCounting];
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[BadHeadersMockNetwork class]];
}

- (void)testInvalidLocationDoesNotCauseCrash
{
    NSUInteger initialInstancesCount = [JFFURLConnection instancesCount];
    
    @autoreleasepool {
    
        __weak GHAsyncTestCase *weakSelf = self;
        SEL testSelector = _cmd;
        
        [self prepare:testSelector];
        
        {
            JFFURLConnectionParams *params = [JFFURLConnectionParams new];
            params.useLiveConnection = NO;
            params.url = [@"http://abrakadabra.com" toURL];
            
            JFFURLConnection *connection = [[JFFURLConnection alloc] initWithURLConnectionParams:params];
            connection.didFinishLoadingBlock = ^(NSError *blockError)
            {
                [weakSelf notify:kGHUnitWaitStatusSuccess
                      forSelector:testSelector];
            };
            
            [connection start];
        }
        
        [self waitForStatus:kGHUnitWaitStatusSuccess
                    timeout:61.];
    }
    GHAssertEquals(initialInstancesCount, [JFFURLConnection instancesCount], @"packet mismatch");
}

- (void)_testMockIsAvailableOnlyForNSUrlConnection
{
    [self prepare:_cmd];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://abrakadabra.com"]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                            delegate:self];
    [conn start];
}

@end
