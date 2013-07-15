#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationAdapter.h"

static const char *const defaultQueueName = "com.jff.async_operations_library.general_queue";

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAndQueue(JFFSyncOperationWithProgress progressLoadDataBlock,
                                                                                  const char *queueName,
                                                                                  BOOL barrier,
                                                                                  dispatch_queue_attr_t attr)
{
    assert(queueName != NULL);
    NSString *str = @(queueName);
    progressLoadDataBlock = [progressLoadDataBlock copy];
    
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>() {
        
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

JFFAsyncOperation asyncOperationWithSyncOperationAndConfigurableQueue(JFFSyncOperation loadDataBlock, const char *queueName, BOOL isSerialQueue)
{
    dispatch_queue_attr_t attr = isSerialQueue ? DISPATCH_QUEUE_SERIAL : DISPATCH_QUEUE_CONCURRENT;
    
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock, queueName, NO, attr);
}

JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock)
{
    return asyncOperationWithSyncOperationAndQueue(loadDataBlock, defaultQueueName);
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock(JFFSyncOperationWithProgress progressLoadDataBlock)
{
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue(progressLoadDataBlock,
                                                                    defaultQueueName,
                                                                    NO,
                                                                    DISPATCH_QUEUE_CONCURRENT);
}
