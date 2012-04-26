#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

#import <JFFScheduler/JFFScheduler.h>

@interface AsyncOperationWithDelayTest : GHAsyncTestCase
@end

@implementation AsyncOperationWithDelayTest

-(void)setUp
{
    [ JFFScheduler enableInstancesCounting ];
}

-(void)testCancelAsyncOperationWithDelay
{
    const NSUInteger initialSchedulerInstancesCount_ = [ JFFScheduler instancesCount ];

    __block BOOL cancelBlockOk_ = NO;
    __block NSTimeInterval timeDifference_ = 0;

    @autoreleasepool
    {
        JFFAsyncOperation loader_ = asyncOperationWithDelay( 0.2 );

        JFFAsyncOperationProgressHandler progressCallback_ = ^( id data_ )
        {
            [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
        };
        JFFCancelAsyncOperationHandler cancelCallback_ = ^( BOOL canceled_ )
        {
            cancelBlockOk_ = canceled_;
        };
        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
        };

        JFFCancelAsyncOperation cancel_ = loader_( progressCallback_
                                                  , cancelCallback_
                                                  , doneCallback_ );

        cancel_( YES );

        NSDate* startDate_ = [ NSDate new ];

        asyncOperationWithDelay( 0.3 )( nil, nil, ^( id result_, NSError* error_ )
        {
            NSDate* finishDate_ = [ NSDate new ];
            timeDifference_ = [ finishDate_ timeIntervalSinceDate: startDate_ ];

            [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
        } );
    }

    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];

    GHAssertTrue( initialSchedulerInstancesCount_ == [ JFFScheduler instancesCount ], @"OK" );

    GHAssertTrue( cancelBlockOk_, @"OK" );
    GHAssertTrue( timeDifference_ >= 0.3, @"OK" );
}

@end
