#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#ifdef __cplusplus
extern "C" {
#endif

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ );

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, const char* queueName_ );

JFFAsyncOperation barrierAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, const char* queueName_ );

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
