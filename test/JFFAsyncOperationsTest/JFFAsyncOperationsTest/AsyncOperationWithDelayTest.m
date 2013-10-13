#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

#import <JFFScheduler/JFFScheduler.h>

@interface AsyncOperationWithDelayTest : GHAsyncTestCase
@end

@implementation AsyncOperationWithDelayTest

- (void)setUp
{
    [JFFScheduler enableInstancesCounting];
}

- (void)testCancelAsyncOperationWithDelay
{
    const NSUInteger initialSchedulerInstancesCount = [JFFScheduler instancesCount];
    
    __block BOOL cancelBlockOk = NO;
    __block NSTimeInterval timeDifference = 0;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock complete) {
        
        @autoreleasepool {
            JFFAsyncOperation loader = asyncOperationWithDelay(.2, .02);
            
            JFFAsyncOperationProgressHandler progressCallback = ^(id data) {
                complete();
            };
            JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
                cancelBlockOk = canceled;
            };
            JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
                complete();
            };
            
            JFFCancelAsyncOperation cancel = loader(progressCallback,
                                                    cancelCallback,
                                                    doneCallback);
            
            cancel(YES);
            
            NSDate *startDate = [NSDate new];
            
            asyncOperationWithDelay(.3, .03)(nil, nil, ^(id result, NSError *error) {
                NSDate *finishDate = [NSDate new];
                timeDifference = [finishDate timeIntervalSinceDate:startDate];
                
                complete();
            });
        }
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1.];
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFScheduler instancesCount], @"OK");
    
    GHAssertTrue(cancelBlockOk, @"OK");
    GHAssertTrue(timeDifference >= 0.3, @"OK");
}

- (void)testAsyncOperationWithDelayTwiceCall
{
    const NSUInteger initialSchedulerInstancesCount = [JFFScheduler instancesCount];
    
    __block NSUInteger callsCount = 0;
    
    void (^block)(JFFSimpleBlock) = ^(JFFSimpleBlock complete) {
        
        @autoreleasepool {
            JFFAsyncOperation loader = asyncOperationWithDelay(.2, .02);
            
            JFFAsyncOperationProgressHandler progressCallback = ^(id data) {
                complete();
            };
            JFFCancelAsyncOperationHandler cancelCallback = ^(BOOL canceled) {
                complete();
            };
            JFFDidFinishAsyncOperationHandler doneCallback = ^(id result, NSError *error) {
                ++callsCount;
                if (callsCount == 2)
                    complete();
            };
            
            loader(progressCallback, cancelCallback, doneCallback);
            loader(progressCallback, cancelCallback, doneCallback);
        }
    };
    
    [self performAsyncRequestOnMainThreadWithBlock:block
                                          selector:_cmd
                                           timeout:1.];
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFScheduler instancesCount], @"OK");
    
    GHAssertTrue(callsCount == 2, @"OK");
}

@end
