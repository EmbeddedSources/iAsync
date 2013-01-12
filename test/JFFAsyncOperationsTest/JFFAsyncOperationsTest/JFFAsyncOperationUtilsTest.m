
@interface JFFAsyncOperationUtilsTest : GHAsyncTestCase
@end

@implementation JFFAsyncOperationUtilsTest

-(void)testCallingOfPregressBlock
{
    NSObject *resultObject = [NSObject new];
    
    JFFSyncOperation loadDataBlock = ^id(NSError **error) {
        return resultObject;
    };
    
    JFFAsyncOperation loader = asyncOperationWithSyncOperationAndQueue(loadDataBlock, "com.test");
    
    __block BOOL resultCalled = NO;
    
    JFFDidFinishAsyncOperationHandler doneCallback_ = ^(id result, NSError *error) {
        resultCalled = YES;
        [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
    };
    
    __block BOOL progressCalled_ = NO;
    __block NSUInteger progressCallsCount   = 0;
    __block BOOL progressCalledBeforeResult = NO;
    
    JFFAsyncOperationProgressHandler progressCallback_ = ^(id info) {
        progressCalled_ = (info == resultObject);
        ++progressCallsCount;
        progressCalledBeforeResult = !resultCalled;
    };

    loader(progressCallback_, nil, doneCallback_);
    
    //TODO sometimes fails - fix !!!
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];

    GHAssertTrue( progressCalled_, @"ok" );
    GHAssertTrue( progressCallsCount == 1, @"ok" );
    GHAssertTrue( progressCalledBeforeResult, @"ok" );
}

@end
