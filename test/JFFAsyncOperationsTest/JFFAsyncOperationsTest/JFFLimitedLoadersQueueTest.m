
#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

#import <JFFAsyncOperations/LoadBalancer/Details2/JFFBaseLoaderOwner.h>

@interface JFFLimitedLoadersQueueTest : GHAsyncTestCase
@end

@implementation JFFLimitedLoadersQueueTest

-(void)setUp
{
    [JFFBaseLoaderOwner enableInstancesCounting];
}

- (void)testPerormTwoBlocksAndOneWaits
{
    const NSUInteger initialSchedulerInstancesCount = [JFFBaseLoaderOwner instancesCount];
    
    @autoreleasepool
    {
        JFFLimitedLoadersQueue *queue = [JFFLimitedLoadersQueue new];
        queue.limitCount = 2;
        
        JFFAsyncOperationManager *loader1 = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *loader2 = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *loader3 = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *loader4 = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation balancedLoader1 = [queue balancedLoaderWithLoader:loader1.loader];
        JFFAsyncOperation balancedLoader2 = [queue balancedLoaderWithLoader:loader2.loader];
        JFFAsyncOperation balancedLoader3 = [queue balancedLoaderWithLoader:loader3.loader];
        JFFAsyncOperation balancedLoader4 = [queue balancedLoaderWithLoader:loader4.loader];
        
        //1. perform 4 blocks with limit - 2 (any finished)
        balancedLoader1(nil, nil, nil);
        balancedLoader2(nil, nil, nil);
        JFFCancelAsyncOperation cancelBalanced3 = balancedLoader3(nil, nil, nil);
        
        __block BOOL canceled4 = NO;
        JFFCancelAsyncOperation cancelBalanced4 = balancedLoader4(nil, ^(BOOL canceled){
            canceled4 = canceled;
        }, nil);
        
        //2. Check that only first two runned
        GHAssertTrue(loader1.loadingCount == 1, nil);
        GHAssertTrue(loader2.loadingCount == 1, nil);
        GHAssertTrue(loader3.loadingCount == 0, nil);
        GHAssertTrue(loader4.loadingCount == 0, nil);
        
        //3. Finish first, check that 3-th was runned
        loader1.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        GHAssertTrue(loader1.finished, nil);
        GHAssertTrue(loader2.loadingCount == 1, nil);
        GHAssertTrue(loader3.loadingCount == 1, nil);
        GHAssertTrue(loader4.loadingCount == 0, nil);
        
        //5. Cancel 4-th and than 3-th,
        // check that 3-th native was canceled
        // check that 4-th was not runned
        cancelBalanced4(YES);
        cancelBalanced3(YES);
        
        GHAssertTrue(loader3.canceled, nil);
        GHAssertTrue(loader4.loadingCount == 0, nil);
        
        //6. Finish second, and check that all loader was finished or canceled
        loader2.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        GHAssertTrue(loader1.finished, nil);
        GHAssertTrue(loader2.finished, nil);
        GHAssertTrue(loader3.canceled, nil);
        GHAssertTrue(canceled4       , nil);
    }
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFBaseLoaderOwner instancesCount], @"OK");
}

- (void)testOneOperationInQueue
{
    const NSUInteger initialSchedulerInstancesCount = [JFFBaseLoaderOwner instancesCount];
    
    @autoreleasepool
    {
        JFFLimitedLoadersQueue *queue = [JFFLimitedLoadersQueue new];
        queue.limitCount = 1;
        
        JFFAsyncOperationManager *loader1 = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *loader2 = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation balancedLoader1 = [queue balancedLoaderWithLoader:loader1.loader];
        JFFAsyncOperation balancedLoader2 = [queue balancedLoaderWithLoader:loader2.loader];
        
        balancedLoader1(nil, nil, nil);
        balancedLoader2(nil, nil, nil);
        
        GHAssertTrue(loader1.loadingCount == 1, nil);
        GHAssertTrue(loader2.loadingCount == 0, nil);
        
        loader1.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        
        GHAssertTrue(loader1.finished, nil);
        GHAssertTrue(loader2.loadingCount == 1, nil);
        
        loader2.loaderFinishBlock.didFinishBlock([NSNull new], nil);
    }
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFBaseLoaderOwner instancesCount], @"OK");
}

- (void)testBarrierLoader
{
    const NSUInteger initialSchedulerInstancesCount = [JFFBaseLoaderOwner instancesCount];
    
    @autoreleasepool
    {
        JFFLimitedLoadersQueue *queue = [JFFLimitedLoadersQueue new];
        queue.limitCount = 3;
        
        JFFAsyncOperationManager *loader1 = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *loader2 = [JFFAsyncOperationManager new];
        JFFAsyncOperationManager *loader3 = [JFFAsyncOperationManager new];
        
        JFFAsyncOperation balancedLoader1 = [queue balancedLoaderWithLoader:loader1.loader];
        JFFAsyncOperation balancedLoader2 = [queue barrierBalancedLoaderWithLoader:loader2.loader];
        JFFAsyncOperation balancedLoader3 = [queue balancedLoaderWithLoader:loader3.loader];
        
        //1. perform all blocks
        balancedLoader1(nil, nil, nil);
        balancedLoader2(nil, nil, nil);
        balancedLoader3(nil, nil, nil);
        
        //2. Check that only first one runned
        GHAssertTrue(loader1.loadingCount == 1, nil);
        GHAssertTrue(loader2.loadingCount == 0, nil);
        GHAssertTrue(loader3.loadingCount == 0, nil);
        
        //3. Finish first, check that 2-th was runned
        loader1.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        GHAssertTrue(loader1.finished, nil);
        GHAssertTrue(loader2.loadingCount == 1, nil);
        GHAssertTrue(loader3.loadingCount == 0, nil);
        
        //4. Finish second and check that 3-th was runned
        loader2.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        GHAssertTrue(loader2.finished == 1, nil);
        GHAssertTrue(loader3.loadingCount == 1, nil);
        
        loader3.loaderFinishBlock.didFinishBlock([NSNull new], nil);
        GHAssertTrue(loader3.finished == 1, nil);
    }
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFBaseLoaderOwner instancesCount], @"OK");
}

//TODO test when (active)native loader was canced
//TODO test usibscribe balanced

@end
