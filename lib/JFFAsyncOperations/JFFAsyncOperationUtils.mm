#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationAdapter.h"

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAndQueue(JFFSyncOperationWithProgress progressLoadDataBlock,
                                                                                  const char *queueName,
                                                                                  BOOL barrier,
                                                                                  dispatch_queue_attr_t attr)
{
    progressLoadDataBlock = [progressLoadDataBlock copy];
    NSString *str = @(queueName?:"");
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFAsyncOperationAdapter *asyncObject = [JFFAsyncOperationAdapter new];
        asyncObject.loadDataBlock = progressLoadDataBlock;
        asyncObject.queueName     = [str cStringUsingEncoding:NSUTF8StringEncoding];
        asyncObject.barrier       = barrier;
        asyncObject.queueAttributes = attr;
        return asyncObject;
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}

static JFFAsyncOperation privateAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                        const char *queueName,
                                                                        BOOL barrier,
                                                                        dispatch_queue_attr_t attr)
{
    loadDataBlock = [loadDataBlock copy];
    JFFSyncOperationWithProgress progressLoadDataBlock= ^id(NSError *__autoreleasing *error,
                                                            JFFAsyncOperationProgressHandler progressCallback) {
        id result = loadDataBlock(error);
        if (result && progressCallback)
            progressCallback(result);
        return result;
    };
    
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue(progressLoadDataBlock,
                                                                    queueName,
                                                                    barrier,
                                                                    attr);
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock, const char *queueName)
{
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                          queueName,
                                                          NO,
                                                          DISPATCH_QUEUE_CONCURRENT);
}

JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                 const char *queueName)
{
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                          queueName,
                                                          YES,
                                                          DISPATCH_QUEUE_CONCURRENT);
}

JFFAsyncOperation asyncOperationWithSyncOperationAndConfigurableQueue( JFFSyncOperation loadDataBlock_, const char* queueName_, BOOL isSerialQueue_ )
{
    dispatch_queue_attr_t attr_ = isSerialQueue_ ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT;
    
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_, queueName_, NO, attr_ );
}

//TODO check using of all asyncOperationWithSyncOperation (without queue name) or remove asyncOperationWithSyncOperation at all
JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock)
{
    return asyncOperationWithSyncOperationAndQueue(loadDataBlock, nil);
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock(JFFSyncOperationWithProgress progressLoadDataBlock)
{
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue(progressLoadDataBlock,
                                                                    nil,
                                                                    NO,
                                                                    DISPATCH_QUEUE_CONCURRENT);
}
