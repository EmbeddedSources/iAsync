
#import <JFFScheduler/JFFScheduler.h>
#import <JFFTestTools/JFFTestTools.h>

#import <JFFAsyncOperations/JFFAsyncOperationContinuity.h>

@interface JFFAsyncOperationHelpersTest : GHAsyncTestCase
@end

@implementation JFFAsyncOperationHelpersTest

- (void)setUp
{
    [JFFTimer                 enableInstancesCounting];
    [JFFAsyncOperationManager enableInstancesCounting];
}

- (void)testCancelFirstLoader
{
    NSUInteger initialInstanceCount1 = [JFFTimer                 instancesCount];
    NSUInteger initialInstanceCount2 = [JFFAsyncOperationManager instancesCount];
    
    @autoreleasepool {
        
        JFFAsyncOperationManager *nativeLoaderManager = [JFFAsyncOperationManager new];
        
        JFFContinueLoaderWithResult continueLoaderBuilder = ^JFFAsyncOperation(id result, NSError *error) {
            
            return nativeLoaderManager.loader;
        };
        
        JFFAsyncOperation loader = repeatAsyncOperationWithDelayLoader(nativeLoaderManager.loader,
                                                                       continueLoaderBuilder,
                                                                       1000);
        
        loader(nil, nil, nil)(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertEquals((NSUInteger)1, nativeLoaderManager.loadingCount, nil);
    }
    
    GHAssertEquals(initialInstanceCount1, [JFFTimer                 instancesCount], nil);
    GHAssertEquals(initialInstanceCount2, [JFFAsyncOperationManager instancesCount], nil);
}

- (void)testCancelTimerLoader
{
    NSUInteger initialInstanceCount1 = [JFFTimer                 instancesCount];
    NSUInteger initialInstanceCount2 = [JFFAsyncOperationManager instancesCount];
    
    @autoreleasepool {
        
        JFFAsyncOperationManager *nativeLoaderManager = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *timerLoaderManager  = [JFFAsyncOperationManager new];
        
        __block BOOL thirdLoaderCreated = NO;
        
        JFFContinueLoaderWithResult continueLoaderBuilder = ^JFFAsyncOperation(id result, NSError *error) {
            
            thirdLoaderCreated = YES;
            
            return sequenceOfAsyncOperations(timerLoaderManager.loader, nativeLoaderManager.loader, nil);
        };
        
        JFFAsyncOperation loader = repeatAsyncOperationWithDelayLoader(nativeLoaderManager.loader,
                                                                       continueLoaderBuilder,
                                                                       1000);
        
        JFFAsyncOperationHandler handler = loader(nil, nil, nil);
        
        nativeLoaderManager.loaderFinishBlock([NSNull new], nil);
        
        handler(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertTrue(thirdLoaderCreated, nil);
        
        GHAssertEquals((NSUInteger)1, nativeLoaderManager.loadingCount, nil);
        GHAssertEquals((NSUInteger)1, timerLoaderManager .loadingCount, nil);
    }
    
    GHAssertEquals(initialInstanceCount1, [JFFTimer                 instancesCount], nil);
    GHAssertEquals(initialInstanceCount2, [JFFAsyncOperationManager instancesCount], nil);
}

- (void)testCallThreeTimesNativeLoader
{
    NSUInteger initialInstanceCount1 = [JFFTimer                 instancesCount];
    NSUInteger initialInstanceCount2 = [JFFAsyncOperationManager instancesCount];
    
    @autoreleasepool {
        
        JFFAsyncOperationManager *nativeLoaderManager = [JFFAsyncOperationManager new];
        nativeLoaderManager.finishAtLoading = YES;
        
        JFFContinueLoaderWithResult continueLoaderBuilder = ^JFFAsyncOperation(id result, NSError *error) {
            
            return result?nativeLoaderManager.loader:nil;
        };
        
        JFFAsyncOperation loader = repeatAsyncOperationWithDelayLoader(nativeLoaderManager.loader,
                                                                       continueLoaderBuilder,
                                                                       3);
        
        JFFAsyncOperationHandler handler = loader(nil, nil, nil);
        
        handler(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertEquals((NSUInteger)4, nativeLoaderManager.loadingCount, nil);
    }
    
    GHAssertEquals(initialInstanceCount1, [JFFTimer                 instancesCount], nil);
    GHAssertEquals(initialInstanceCount2, [JFFAsyncOperationManager instancesCount], nil);
}

- (void)testCallThreeTimesNativeLoaderOnError
{
    NSUInteger initialInstanceCount1 = [JFFTimer                 instancesCount];
    NSUInteger initialInstanceCount2 = [JFFAsyncOperationManager instancesCount];
    
    @autoreleasepool {
        
        JFFAsyncOperationManager *nativeLoaderManager = [JFFAsyncOperationManager new];
        nativeLoaderManager.failAtLoading = YES;
        
        JFFContinueLoaderWithResult continueLoaderBuilder = ^JFFAsyncOperation(id result, NSError *error) {
            
            return error?nativeLoaderManager.loader:nil;
        };
        
        JFFAsyncOperation loader = repeatAsyncOperationWithDelayLoader(nativeLoaderManager.loader,
                                                                       continueLoaderBuilder,
                                                                       3);
        
        JFFAsyncOperationHandler handler = loader(nil, nil, nil);
        
        handler(JFFAsyncOperationHandlerTaskCancel);
        
        GHAssertEquals((NSUInteger)4, nativeLoaderManager.loadingCount, nil);
    }
    
    GHAssertEquals(initialInstanceCount1, [JFFTimer                 instancesCount], nil);
    GHAssertEquals(initialInstanceCount2, [JFFAsyncOperationManager instancesCount], nil);
}

@end
