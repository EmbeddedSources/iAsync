#import "JFFAsyncOperationUtils.h"

#import "JFFAsyncOperationBuilder.h"
#import "JFFAsyncOperationAdapter.h"

static const char *const defaultQueueName = "com.jff.async_operations_library.general_queue";

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAndQueue(JFFSyncOperationWithProgress progressLoadDataBlock,
                                                                                  const char *queueName,
                                                                                  BOOL barrier,
                                                                                  dispatch_queue_t currentQueue,
                                                                                  dispatch_queue_attr_t attr)
{
    NSCParameterAssert(queueName != NULL);
    NSString *str = @(queueName);
    progressLoadDataBlock = [progressLoadDataBlock copy];
    
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>() {
        
        JFFAsyncOperationAdapter *asyncObject = [JFFAsyncOperationAdapter new];
        asyncObject.loadDataBlock   = progressLoadDataBlock;
        asyncObject.queueName       = [str cStringUsingEncoding:NSUTF8StringEncoding];
        asyncObject.barrier         = barrier;
        asyncObject.currentQueue    = currentQueue;
        asyncObject.queueAttributes = attr;
        return asyncObject;
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}

static JFFAsyncOperation privateAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                        const char *queueName,
                                                                        BOOL barrier,
                                                                        dispatch_queue_t currentQueue,
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
                                                                    currentQueue,
                                                                    attr);
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock, const char *queueName)
{
    NSCParameterAssert([NSThread isMainThread]);
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                          queueName,
                                                          NO,
                                                          dispatch_get_main_queue(),
                                                          DISPATCH_QUEUE_CONCURRENT);
}

JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                 const char *queueName)
{
    NSCParameterAssert([NSThread isMainThread]);
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                          queueName,
                                                          YES,
                                                          dispatch_get_main_queue(),
                                                          DISPATCH_QUEUE_CONCURRENT);
}

JFFAsyncOperation asyncOperationWithSyncOperationAndConfigurableQueue(JFFSyncOperation loadDataBlock, const char *queueName, BOOL isSerialQueue)
{
    NSCParameterAssert([NSThread isMainThread]);
    dispatch_queue_attr_t attr = isSerialQueue?DISPATCH_QUEUE_SERIAL:DISPATCH_QUEUE_CONCURRENT;
    
    return privateAsyncOperationWithSyncOperationAndQueue(loadDataBlock,
                                                          queueName,
                                                          NO,
                                                          dispatch_get_main_queue(),
                                                          attr);
}

JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock)
{
    return asyncOperationWithSyncOperationAndQueue(loadDataBlock, defaultQueueName);
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock(JFFSyncOperationWithProgress progressLoadDataBlock)
{
    NSCParameterAssert([NSThread isMainThread]);
    return asyncOperationWithSyncOperationWithProgressBlockAndQueue(progressLoadDataBlock,
                                                                    defaultQueueName,
                                                                    NO,
                                                                    dispatch_get_main_queue(),
                                                                    DISPATCH_QUEUE_CONCURRENT);
}
