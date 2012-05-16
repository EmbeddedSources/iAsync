#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationOperation.h"

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAmdQueue( JFFSyncOperationWithProgress progressLoadDataBlock_
                                                                                  , NSString* queueName_
                                                                                  , BOOL concurent_ )
{
    JFFAsyncOperationOperation* asyncObj_ = [ JFFAsyncOperationOperation new ];
    asyncObj_.loadDataBlock = progressLoadDataBlock_;
    asyncObj_.queueName     = queueName_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

static JFFAsyncOperation privateAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_
                                                                        , NSString* queueName_
                                                                        , BOOL concurrent_ )
{
    loadDataBlock_ = [ loadDataBlock_ copy ];
    JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                              , JFFAsyncOperationProgressHandler progressCallback_ )
    {
        //JTODO test this if
        id result_ = loadDataBlock_( error_ );
        if ( result_ && progressCallback_ )
            progressCallback_( result_ );
        return result_;
    };

    return asyncOperationWithSyncOperationWithProgressBlockAmdQueue( progressLoadDataBlock_
                                                                    , queueName_
                                                                    , concurrent_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , YES );
}

JFFAsyncOperation serialAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , NO );
}

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ )
{
    return asyncOperationWithSyncOperationAndQueue( loadDataBlock_, nil );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ )
{
    return asyncOperationWithSyncOperationWithProgressBlockAmdQueue( progressLoadDataBlock_
                                                                    , nil
                                                                    , YES );
}
