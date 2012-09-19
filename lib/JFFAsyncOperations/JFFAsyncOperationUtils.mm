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

static JFFAsyncOperation privateAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                        const char* queueName,
                                                                        BOOL barrier )
{
    loadDataBlock = [loadDataBlock copy];
    JFFSyncOperationWithProgress progressLoadDataBlock= ^id(NSError *__autoreleasing *error,
                                                            JFFAsyncOperationProgressHandler progressCallback)
    {
        id result = loadDataBlock(error);
        if (result && progressCallback)
            progressCallback(result);
        return result;
    };
    
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue(progressLoadDataBlock,
                                                                    queueName,
                                                                    barrier );
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock, const char *queueName)
{
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                          queueName,
                                                          NO );
}

JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, const char* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , YES );
}

JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock)
{
    return asyncOperationWithSyncOperationAndQueue(loadDataBlock, nil);
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ )
{
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue( progressLoadDataBlock_
                                                                    , nil
                                                                    , NO );
}
