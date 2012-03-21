
#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface ParalelBlockTest : GHAsyncTestCase
@end

@implementation ParalelBlockTest

-(void)testParalelTask
{
    __block BOOL theSameThread_ = NO;

    @autoreleasepool
    {
        dispatch_queue_t currentQueue_ = dispatch_get_current_queue();

        JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                                  , JFFAsyncOperationProgressHandler progressCallback_ )
        {
            progressCallback_( [ NSNull null ] );
//            sleep( 0.1 );
            return [ NSNull null ];
        };
        JFFAsyncOperation loader_ = asyncOperationWithSyncOperationWithProgressBlock( progressLoadDataBlock_ );

        JFFDidFinishAsyncOperationHandler doneCallback_ = ^( id result_, NSError* error_ )
        {
            theSameThread_ = ( currentQueue_ == dispatch_get_current_queue() );

            if ( result_ )
            {
                [ self notify: kGHUnitWaitStatusSuccess forSelector: _cmd ];
            }
            else
            {
                [ self notify: kGHUnitWaitStatusFailure forSelector: _cmd ];
            }
        };

        loader_( nil, nil, doneCallback_ );
    }

    [ self prepare ];
    [ self waitForStatus: kGHUnitWaitStatusSuccess timeout: 1. ];

    GHAssertTrue( theSameThread_, @"OK" );
}

@end
