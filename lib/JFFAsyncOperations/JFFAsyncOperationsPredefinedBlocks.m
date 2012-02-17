#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFCancelAyncOperationBlockHolder.h"

#import <JFFScheduler/JFFScheduler.h>

//JTODO rename to JFFStubCancelAsyncOperationBlock
JFFCancelAsyncOperation JFFEmptyCancelAsyncOperationBlock = ^void( BOOL cancel_ ){ /*do nothing*/ };

JFFAsyncOperation JFFAsyncOperationBlockWithSuccessResult =
^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                         , JFFCancelAsyncOperationHandler cancel_callback_
                         , JFFDidFinishAsyncOperationHandler doneCallback_ )
{
    if ( doneCallback_ )
        doneCallback_( [ NSNull null ], nil );
    return ^void( BOOL cancel_ ){ /*do nothing*/ };
};

JFFAsyncOperation asyncOperationBlockWithSuccessResultAfterDelay( NSTimeInterval delay_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                    , JFFCancelAsyncOperationHandler cancel_callback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        if ( !doneCallback_ )
            return JFFEmptyCancelAsyncOperationBlock;

        JFFScheduler* scheduer_ = [ JFFScheduler new ];

        JFFScheduledBlock scheduled_block_ = ^void( JFFCancelScheduledBlock cancel_ )
        {
            cancel_();
            doneCallback_( [ NSNull null ], nil );
        };
        JFFCancelScheduledBlock cancel_scheduler_ = [ scheduer_ addBlock: scheduled_block_ duration: delay_ ];

        JFFCancelAyncOperationBlockHolder* cancel_holder_ = [ JFFCancelAyncOperationBlockHolder new ];

        cancel_callback_ = [ cancel_callback_ copy ];
        cancel_holder_.cancelBlock = ^void( BOOL cancel_ )
        {
            cancel_scheduler_();

            if ( cancel_callback_ )
                cancel_callback_( cancel_ );
        };

        return cancel_holder_.onceCancelBlock;
    };
}
