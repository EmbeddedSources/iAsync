
#import <JFFScheduler/JFFScheduler.h>
#import <JFFTestTools/JFFTestTools.h>

@interface JFFSchedulerTest : GHAsyncTestCase
@end

@implementation JFFSchedulerTest

-(void)setUp
{
    [ JFFScheduler enableInstancesCounting ];
}

-(void)testCancelWhenDeallocedScheduler
{
    __block BOOL fired_ = NO;
    JFFScheduler* sharedScheduler_ = [ JFFScheduler sharedByThreadScheduler ];
    const NSUInteger initialSchedulerInstancesCount_ = [ JFFScheduler instancesCount ];
    __block NSTimeInterval timeDifference_ = 0;
    
    @autoreleasepool {
        [[JFFScheduler new] addBlock:^(JFFCancelScheduledBlock cancel_) {
            cancel_();
            fired_ = YES;
        } duration: 0.1 ];
        
        NSDate* startDate_ = [ NSDate new ];
        
        [sharedScheduler_ addBlock:^(JFFCancelScheduledBlock cancel_) {
            NSDate* finishDate_ = [ NSDate new ];
            timeDifference_ = [ finishDate_ timeIntervalSinceDate: startDate_ ];
            
            cancel_();
            [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];
        } duration: 0.2 ];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse( fired_, @"OK" );
    GHAssertTrue( initialSchedulerInstancesCount_ == [ JFFScheduler instancesCount ], @"OK" );
    GHAssertTrue( timeDifference_ >= 0.2, @"OK" );
}

-(void)testCancelBlockReturned
{
    __block BOOL fired_ = NO;
    JFFScheduler* sharedScheduler_ = [ JFFScheduler sharedByThreadScheduler ];
    const NSUInteger initialSchedulerInstancesCount_ = [ JFFScheduler instancesCount ];
    __block NSTimeInterval timeDifference_ = 0;
    
    @autoreleasepool {
        JFFCancelScheduledBlock mainCancel_ = [ [ JFFScheduler new ] addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
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
    GHAssertTrue( initialSchedulerInstancesCount_ == [ JFFScheduler instancesCount ], @"OK" );
    GHAssertTrue( timeDifference_ >= 0.3, @"OK" );
}

-(void)testCancelAllScheduledOperations
{
    __block BOOL fired_ = NO;
    JFFScheduler* sharedScheduler_ = [ JFFScheduler sharedByThreadScheduler ];
    const NSUInteger initialSchedulerInstancesCount_ = [ JFFScheduler instancesCount ];
    __block NSTimeInterval timeDifference_ = 0;

    @autoreleasepool {
        JFFScheduler *scheduler_ = [ JFFScheduler new ];
        [ scheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
            cancel_();
            fired_ = YES;
        } duration: 0.2 ];
        [ scheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
            cancel_();
            fired_ = YES;
        } duration: 0.2 ];
        
        [ sharedScheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
            [ scheduler_ cancelAllScheduledOperations ];
            cancel_();
        } duration: 0.1 ];

        NSDate *startDate_ = [NSDate new];

        [sharedScheduler_ addBlock: ^( JFFCancelScheduledBlock cancel_ ) {
            NSDate* finishDate_ = [ NSDate new ];
            timeDifference_ = [ finishDate_ timeIntervalSinceDate: startDate_ ];
            
            cancel_();
            [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
        } duration: 0.3 ];
        
        //GHAssertTrue( 0 != [ JFFScheduler instancesCount ], @"OK" );
    }
    
    [self prepare];
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:1.];
    
    GHAssertFalse( fired_, @"OK" );
    GHAssertTrue( initialSchedulerInstancesCount_ == [ JFFScheduler instancesCount ], @"OK" );
    GHAssertTrue( timeDifference_ >= 0.2, @"OK" );
}

-(void)testNotmalScheduledOperationTwice
{
    JFFScheduler* sharedScheduler_ = [ JFFScheduler sharedByThreadScheduler ];
    const NSUInteger initialSchedulerInstancesCount_ = [ JFFScheduler instancesCount ];
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
    
    GHAssertTrue(initialSchedulerInstancesCount_ == [JFFScheduler instancesCount], @"OK");
    GHAssertTrue(timeDifference_ >= 0.2, @"OK");
}

@end
