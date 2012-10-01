
@interface JFFAsyncOperationUtilsTest : GHAsyncTestCase
@end

@implementation JFFAsyncOperationUtilsTest

-(void)testCallingOfPregressBlock
{
    NSObject *resultObject = [NSObject new];
    
    JFFSyncOperation loadDataBlock_ = ^id( NSError** error_ ) {
        return resultObject;
    };
    
    JFFAsyncOperation loader_ = asyncOperationWithSyncOperationAndQueue( loadDataBlock_, "com.test" );
    
    __block BOOL resultCalled_ = NO;
    
    JFFDidFinishAsyncOperationHandler doneCallback_ = ^(id result, NSError *error) {
        resultCalled_ = YES;
        [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
    };
    
    __block BOOL progressCalled_ = NO;
    __block NSUInteger progressCallsCount_ = 0;
    __block BOOL progressCalledBeforeResult_ = NO;
    
    JFFAsyncOperationProgressHandler progressCallback_ = ^(id info_) {
        progressCalled_ = ( info_ == resultObject );
        ++progressCallsCount_;
        progressCalledBeforeResult_ = !resultCalled_;
    };
    
    loader_( progressCallback_, nil, doneCallback_ );
    
    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];
    
    GHAssertTrue( progressCalled_, @"ok" );
    GHAssertTrue( progressCallsCount_ == 1, @"ok" );
    GHAssertTrue( progressCalledBeforeResult_, @"ok" );
}

@end
