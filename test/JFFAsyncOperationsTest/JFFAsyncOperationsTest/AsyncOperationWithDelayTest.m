#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

#import <JFFScheduler/JFFScheduler.h>

@interface AsyncOperationWithDelayTest : GHAsyncTestCase
@end

@implementation AsyncOperationWithDelayTest

-(void)setUp
{
    [JFFScheduler enableInstancesCounting];
}

-(void)testCancelAsyncOperationWithDelay
{
    const NSUInteger initialSchedulerInstancesCount = [JFFScheduler instancesCount];
    
    __block BOOL cancelBlockOk = NO;
    __block NSTimeInterval timeDifference = 0;
    
    @autoreleasepool {
        JFFAsyncOperation loader = asyncOperationWithDelay(.2);
        
        JFFAsyncOperationProgressHandler progressCallback = ^(id data) {
            [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
        };
        JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
            cancelBlockOk = canceled;
        };
        JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
            [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
        };
        
        JFFCancelAsyncOperation cancel = loader(progressCallback,
                                                cancelCallback,
                                                doneCallback);
        
        cancel(YES);
        
        NSDate *startDate = [NSDate new];
        
        asyncOperationWithDelay(.3)(nil, nil, ^(id result, NSError *error) {
            NSDate *finishDate = [NSDate new];
            timeDifference = [finishDate timeIntervalSinceDate:startDate];
            
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        });
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFScheduler instancesCount], @"OK");
    
    GHAssertTrue(cancelBlockOk, @"OK");
    GHAssertTrue(timeDifference >= 0.3, @"OK");
}

-(void)testAsyncOperationWithDelayTwiceCall
{
    const NSUInteger initialSchedulerInstancesCount = [JFFScheduler instancesCount];
    
    __block NSUInteger callsCount = 0;
    
    @autoreleasepool {
        JFFAsyncOperation loader = asyncOperationWithDelay(.2);
        
        JFFAsyncOperationProgressHandler progressCallback = ^(id data) {
            [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
        };
        JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
            [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
        };
        JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
            ++callsCount;
            if (callsCount == 2)
                [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        };
        
        loader(progressCallback, cancelCallback, doneCallback);
        loader(progressCallback, cancelCallback, doneCallback);
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFScheduler instancesCount], @"OK");
    
    GHAssertTrue(callsCount == 2, @"OK");
}

@end
