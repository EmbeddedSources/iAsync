
@interface JFFAsyncOperationUtilsTest : GHAsyncTestCase
@end

@implementation JFFAsyncOperationUtilsTest

-(void)testCallingOfPregressBlock
{
    __block BOOL progressCalled = NO;
    __block NSUInteger progressCallsCount   = 0;
    __block BOOL progressCalledBeforeResult = NO;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock complete) {
        
        NSObject *resultObject = [NSObject new];
        
        JFFSyncOperation loadDataBlock = ^id(NSError **error) {
            return resultObject;
        };
        
        JFFAsyncOperation loader = asyncOperationWithSyncOperationAndQueue(loadDataBlock, "com.test");
        
        __block BOOL resultCalled = NO;
        
        JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
            resultCalled = YES;
            complete();
        };
        
        JFFAsyncOperationProgressHandler progressCallback = ^(id info) {
            progressCalled = (info == resultObject);
            ++progressCallsCount;
            progressCalledBeforeResult = !resultCalled;
        };
        
        loader(progressCallback, nil, doneCallback);
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1.];
    
    GHAssertTrue(progressCalled, @"ok");
    GHAssertTrue(progressCallsCount == 1, @"ok");
    GHAssertTrue(progressCalledBeforeResult, @"ok");
}

@end
