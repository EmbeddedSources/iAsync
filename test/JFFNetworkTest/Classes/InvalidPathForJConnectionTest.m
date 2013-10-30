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
    void (^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishTest) {
        
        JFFURLConnectionParams *params = [JFFURLConnectionParams new];
        params.useLiveConnection = NO;
        params.url = [@"http://abrakadabra.com" toURL];
        
        JFFURLConnection *connection = [[JFFURLConnection alloc] initWithURLConnectionParams:params];
        connection.didFinishLoadingBlock = ^(NSError *blockError) {
            
            finishTest();
        };
        
        [connection start];
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd
                                           timeout:61.];
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
