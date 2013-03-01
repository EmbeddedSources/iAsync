#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation asyncOperationWithSyncOperation(JFFSyncOperation loadDataBlock);

    JFFAsyncOperation asyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                              const char *queueName);

    JFFAsyncOperation asyncOperationWithSyncOperationAndConfigurableQueue( JFFSyncOperation loadDataBlock_, const char* queueName_, BOOL isSerialQueue_ );

    JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue(JFFSyncOperation loadDataBlock,
                                                                     const char *queueName);

    JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock(JFFSyncOperationWithProgress progressLoadDataBlock);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
