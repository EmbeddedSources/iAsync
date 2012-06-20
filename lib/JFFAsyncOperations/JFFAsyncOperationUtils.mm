#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationAdapter.h"

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAndQueue( JFFSyncOperationWithProgress progressLoadDataBlock_
                                                                                  , const char* queueName_
                                                                                  , BOOL barrier_ )
{
    JFFAsyncOperationAdapter* asyncObj_ = [ JFFAsyncOperationAdapter new ];
    asyncObj_.loadDataBlock = progressLoadDataBlock_;
    asyncObj_.queueName     = queueName_ ?: "";
    asyncObj_.barrier       = barrier_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

static JFFAsyncOperation privateAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_
                                                                        , const char* queueName_
                                                                        , BOOL barrier_ )
{
    loadDataBlock_ = [ loadDataBlock_ copy ];
    JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                              , JFFAsyncOperationProgressHandler progressCallback_ )
    {
        id result_ = loadDataBlock_( error_ );
        if ( result_ && progressCallback_ )
            progressCallback_( result_ );
        return result_;
    };

    return asyncOperationWithSyncOperationWithProgressBlockAndQueue( progressLoadDataBlock_
                                                                    , queueName_
                                                                    , barrier_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, const char* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , NO );
}

JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, const char* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , YES );
}

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ )
{
    return asyncOperationWithSyncOperationAndQueue( loadDataBlock_, nil );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ )
{
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue( progressLoadDataBlock_
                                                                    , nil
                                                                    , NO );
}
