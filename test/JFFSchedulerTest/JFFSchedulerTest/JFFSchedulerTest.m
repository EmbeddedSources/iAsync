
#import <JFFScheduler/JFFTimer.h>
#import <JFFTestTools/JFFTestTools.h>

@interface JFFSchedulerTest : GHAsyncTestCase
@end

@implementation JFFSchedulerTest

- (void)setUp
{
    [JFFTimer enableInstancesCounting];
}

- (void)testCancelWhenDeallocedScheduler
{
    JFFTimer *sharedScheduler = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount = [JFFTimer instancesCount];
    
    __block BOOL fired = NO;
    __block NSTimeInterval timeDifference = 0;
    
    @autoreleasepool {
        
        [[JFFTimer new] addBlock:^(JFFCancelScheduledBlock cancel) {
            
            cancel();
            fired = YES;
        } duration:0.1];
        
        NSDate *startDate = [NSDate new];
        
        [sharedScheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            
            NSDate *finishDate = [NSDate new];
            timeDifference = [finishDate timeIntervalSinceDate:startDate];
            
            cancel();
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        } duration:0.2];
        
        //GHAssertTrue( 0 != [JFFTimer instancesCount], @"OK");
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse(fired, @"OK" );
    GHAssertTrue(timeDifference >= 0.2, @"OK" );
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFTimer instancesCount], @"OK");
}

- (void)testCancelBlockReturned
{
    JFFTimer *sharedScheduler = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount = [JFFTimer instancesCount];
    
    __block BOOL fired = NO;
    __block NSTimeInterval timeDifference = 0;
    
    @autoreleasepool {
        
        JFFCancelScheduledBlock mainCancel = [[JFFTimer new] addBlock:^(JFFCancelScheduledBlock cancel) {
            cancel();
            fired = YES;
        } duration:0.2];
        
        [sharedScheduler addBlock:^void(JFFCancelScheduledBlock cancel) {
            mainCancel();
            cancel();
        } duration:0.1];
        
        NSDate *startDate = [NSDate new];
        
        [sharedScheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            
            NSDate *finishDate = [NSDate new];
            timeDifference = [finishDate timeIntervalSinceDate:startDate];
            
            cancel();
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        } duration:0.3];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse(fired, @"OK" );
    GHAssertTrue(timeDifference >= 0.3, @"OK" );
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFTimer instancesCount], @"OK");
}

- (void)testCancelAllScheduledOperations
{
    JFFTimer *sharedScheduler = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount = [JFFTimer instancesCount];
    
    __block BOOL fired = NO;
    __block NSTimeInterval timeDifference = 0;
    
    @autoreleasepool {
        
        JFFTimer *timer = [JFFTimer new];
        
        [timer addBlock:^(JFFCancelScheduledBlock cancel) {
            cancel();
            fired = YES;
        } duration:0.6 leeway:0.];
        
        [timer addBlock:^(JFFCancelScheduledBlock cancel) {
            cancel();
            fired = YES;
        } duration:0.6 leeway:0.];
        
        [sharedScheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            [timer cancelAllScheduledOperations];
            cancel();
        } duration:0.1 leeway:0.];
        
        NSDate *startDate = [NSDate new];
        
        [sharedScheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            NSDate *finishDate = [NSDate new];
            timeDifference = [finishDate timeIntervalSinceDate:startDate];
            
            cancel();
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        } duration:0.6 leeway:0.];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse(fired, @"OK");
    GHAssertTrue(timeDifference >= 0.2, @"OK" );
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFTimer instancesCount], @"OK");
}

- (void)testNotmalScheduledOperationTwice
{
    JFFTimer *sharedScheduler = [JFFTimer sharedByThreadTimer];
    
    const NSUInteger initialSchedulerInstancesCount = [JFFTimer instancesCount];
    __block NSTimeInterval timeDifference = 0;
    
    @autoreleasepool {
        
        NSDate *startDate = [NSDate new];
        
        __block BOOL fired = NO;
        [sharedScheduler addBlock:^void(JFFCancelScheduledBlock cancel) {
            
            if (fired) {
                
                NSDate *finishDate = [NSDate new];
                timeDifference = [finishDate timeIntervalSinceDate:startDate];
                
                cancel();
                [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
            }
            
            fired = YES;
        } duration:0.2];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertTrue(timeDifference >= 0.2, @"OK");
    
    GHAssertTrue(initialSchedulerInstancesCount == [JFFTimer instancesCount], @"OK");
}

@end
