
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
    __block BOOL fired = NO;
    JFFTimer *sharedScheduler = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount_ = [JFFTimer instancesCount];
    __block NSTimeInterval timeDifference_ = 0;
    
    @autoreleasepool {
        [[JFFTimer new] addBlock:^(JFFCancelScheduledBlock cancel) {
            cancel();
            fired = YES;
        } duration: 0.1 ];
        
        NSDate* startDate_ = [ NSDate new ];
        
        [sharedScheduler addBlock:^(JFFCancelScheduledBlock cancel) {
            NSDate* finishDate_ = [ NSDate new ];
            timeDifference_ = [ finishDate_ timeIntervalSinceDate: startDate_ ];
            
            cancel();
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        } duration: 0.2 ];
        
        //GHAssertTrue( 0 != [JFFTimer instancesCount], @"OK");
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse(fired, @"OK" );
    GHAssertTrue(initialSchedulerInstancesCount_ == [JFFTimer instancesCount], @"OK");
    GHAssertTrue(timeDifference_ >= 0.2, @"OK" );
}

- (void)testCancelBlockReturned
{
    __block BOOL fired_ = NO;
    JFFTimer *sharedScheduler_ = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount_ = [JFFTimer instancesCount];
    __block NSTimeInterval timeDifference_ = 0;
    
    @autoreleasepool {
        JFFCancelScheduledBlock mainCancel_ = [[JFFTimer new] addBlock:^(JFFCancelScheduledBlock cancel_) {
            cancel_();
            fired_ = YES;
        } duration: 0.2 ];
        
        [sharedScheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
            mainCancel_();
            cancel_();
        } duration: 0.1 ];
        
        NSDate* startDate_ = [NSDate new];
        
        [sharedScheduler_ addBlock:^(JFFCancelScheduledBlock cancel_) {
            NSDate* finishDate_ = [ NSDate new ];
            timeDifference_ = [ finishDate_ timeIntervalSinceDate: startDate_ ];
            
            cancel_();
            [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
        } duration: 0.3 ];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];
    
    GHAssertFalse( fired_, @"OK" );
    GHAssertTrue( initialSchedulerInstancesCount_ == [JFFTimer instancesCount], @"OK");
    GHAssertTrue( timeDifference_ >= 0.3, @"OK" );
}

- (void)testCancelAllScheduledOperations
{
    __block BOOL fired = NO;
    JFFTimer *sharedScheduler = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount = [JFFTimer instancesCount];
    __block NSTimeInterval timeDifference = 0;
    
    @autoreleasepool {
        
        JFFTimer *timer = [JFFTimer new];
        
        [timer addBlock:^(JFFCancelScheduledBlock cancel) {
            cancel();
            fired = YES;
        } duration:0.3 leeway:0.];
        
        [timer addBlock:^(JFFCancelScheduledBlock cancel) {
            cancel();
            fired = YES;
        } duration:0.3 leeway:0.];
        
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
        } duration:0.3 leeway:0.];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse(fired, @"OK");
    GHAssertTrue(initialSchedulerInstancesCount == [JFFTimer instancesCount], @"OK");
    GHAssertTrue(timeDifference >= 0.2, @"OK" );
}

- (void)testNotmalScheduledOperationTwice
{
    JFFTimer *sharedScheduler_ = [JFFTimer sharedByThreadTimer];
    const NSUInteger initialSchedulerInstancesCount_ = [JFFTimer instancesCount];
    __block NSTimeInterval timeDifference_ = 0;
    
    @autoreleasepool {
        NSDate* startDate_ = [ NSDate new ];
        
        __block BOOL fired_ = NO;
        [ sharedScheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
            if ( fired_ ) {
                NSDate* finishDate_ = [ NSDate new ];
                timeDifference_ = [ finishDate_ timeIntervalSinceDate: startDate_ ];
                
                cancel_();
                [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
            }
            
            fired_ = YES;
        } duration: 0.2 ];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];
    
    GHAssertTrue(initialSchedulerInstancesCount_ == [JFFTimer instancesCount], @"OK");
    GHAssertTrue(timeDifference_ >= 0.2, @"OK");
}

@end
