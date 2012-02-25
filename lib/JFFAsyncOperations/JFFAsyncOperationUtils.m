#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationProgressBlockHolder.h"
#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation load_data_block_ )
{
    load_data_block_ = [ [ load_data_block_ copy ] autorelease ];
    b progress_load_data_block_ = ^id( NSError** error_
                                                                 , JFFAsyncOperationProgressHandler progress_callback_ )
    {
        return load_data_block_( error_ );
    };

    return asyncOperationWithSyncOperationWithProgressBlock( progress_load_data_block_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progress_load_data_block_ )
{
    progress_load_data_block_ = [ [ progress_load_data_block_ copy ] autorelease ];
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler pregressInfoCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        dispatch_queue_t current_queue_ = dispatch_get_current_queue();
        dispatch_retain( current_queue_ );

        JFFAsyncOperationProgressBlockHolder* pregress_holder_ = nil;
        if ( pregressInfoCallback_ )
        {
            pregress_holder_      = [ [ JFFAsyncOperationProgressBlockHolder new ] autorelease ];
            pregressInfoCallback_ = [ [ pregressInfoCallback_ copy ] autorelease ];
            pregress_holder_.progressBlock = ^void( id progress_info_ )
            {
                dispatch_async( current_queue_,
                               ^void( void )
                               {
                                   pregressInfoCallback_( progress_info_ );
                               } );
            };
        }

        JFFSyncOperation load_data_block_ = ^id( NSError** error_ )
        {
            JFFAsyncOperationProgressHandler thread_progress_load_data_block_ = ^void( id progress_info_ )
            {
                if ( pregress_holder_.progressBlock )
                    pregress_holder_.progressBlock( progress_info_ );
            };
            return progress_load_data_block_( error_, thread_progress_load_data_block_ );
        };

        JFFCancelAyncOperationBlockHolder* cancelHolder_ = [ [ JFFCancelAyncOperationBlockHolder new ] autorelease ];

        JFFDidFinishAsyncOperationBlockHolder* finish_holder_ = [ [ JFFDidFinishAsyncOperationBlockHolder new ] autorelease ];
        doneCallback_ = [ [ doneCallback_ copy ] autorelease ];
        finish_holder_.didFinishBlock = ^void( id result_, NSError* error_ )
        {
            cancelHolder_.cancelBlock = nil;
            dispatch_release( current_queue_ );

            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };

        JFFBlockOperation* operation_ = [ JFFBlockOperation performOperationWithLoadDataBlock: load_data_block_
                                                                             didLoadDataBlock: finish_holder_.onceDidFinishBlock ];

        cancelCallback_ = [ [ cancelCallback_ copy ] autorelease ];
        cancelHolder_.cancelBlock = ^void( BOOL cancel_ )
        {
            if ( cancelCallback_ )
                cancelCallback_( cancel_ );

            pregress_holder_.progressBlock = nil;
            finish_holder_.didFinishBlock  = nil;
            dispatch_release( current_queue_ );

            if ( cancel_ )
                [ operation_ cancel ];
        };

        return cancelHolder_.onceCancelBlock;
    } copy ] autorelease ];
}
