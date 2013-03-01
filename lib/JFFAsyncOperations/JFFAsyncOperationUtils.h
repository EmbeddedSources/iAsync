#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock);

    JFFAsyncOperation asyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                              const char *queueName);

    JFFAsyncOperation asyncOperationWithSyncOperationAndConfigurableQueue(JFFSyncOperation loadDataBlock, const char* queueName, BOOL isSerialQueue);
    
    JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                     const char *queueName);

    JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock(JFFSyncOperationWithProgress progressLoadDataBlock);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
