#import "BadHeadersMockNetwork.h"

static const NSTimeInterval TIMEOUT = 10.f;

@interface InvalidPathForJConnectionTest : GHAsyncTestCase< NSURLConnectionDelegate >
@end

@implementation InvalidPathForJConnectionTest

-(void)setUp
{
    [ NSURLProtocol registerClass: [ BadHeadersMockNetwork class ] ];
}

-(void)tearDown
{
    [ NSURLProtocol unregisterClass: [ BadHeadersMockNetwork class ] ];   
}

-(void)testInvalidLocationDoesNotCauseCrash
{
    __weak GHAsyncTestCase* weakSelf_ = self;
    SEL testSelector_ = _cmd;
    
    [ self prepare: _cmd ];
    
    JFFURLConnection* connection_ = nil;
    JFFURLConnectionParams* params_ = nil;
    
    {
        params_ = [ JFFURLConnectionParams new ];
        params_.useLiveConnection = NO;
        params_.url = [ NSURL URLWithString: @"http://abrakadabra.com" ];       

        connection_ = [ [ JFFURLConnection alloc ] initWithURLConnectionParams: params_ ];
        connection_.didFinishLoadingBlock = ^( NSError* blockError_)
        {
            [ weakSelf_ notify: kGHUnitWaitStatusSuccess
                   forSelector: testSelector_ ];
        };
        
        [ connection_ start ];
    }
    
    [ self waitForStatus: kGHUnitWaitStatusSuccess
                 timeout: TIMEOUT ];
}

-(void)_testMockIsAvailableOnlyForNSUrlConnection
{
    [ self prepare: _cmd ];
    
    NSURLRequest* request_ = [ NSURLRequest requestWithURL: [ NSURL URLWithString: @"http://abrakadabra.com" ] ];
    NSURLConnection* conn_ = [ [ NSURLConnection alloc ] initWithRequest: request_
                                                                delegate: self ];
    [ conn_ start ];
}

- (void)connection:(NSURLConnection *)connection_
didReceiveResponse:(NSURLResponse *)response_
{
    [ self notify: kGHUnitWaitStatusSuccess
      forSelector: @selector(testInvalidLocationDoesNotCauseCrash) ];
}

@end
