#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    JFFAsyncOperation generalAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                     const char *queueName,
                                                                     BOOL barrier,
                                                                     dispatch_queue_t currentQueue,
                                                                     dispatch_queue_attr_t attr);
    
    JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock);
    
    JFFAsyncOperation asyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                              const char *queueName);
    
    JFFAsyncOperation asyncOperationWithSyncOperationAndConfigurableQueue(JFFSyncOperation loadDataBlock, const char *queueName, BOOL isSerialQueue);
    
    JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                     const char *queueName);
    
    JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock(JFFSyncOperationWithProgress progressLoadDataBlock);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
