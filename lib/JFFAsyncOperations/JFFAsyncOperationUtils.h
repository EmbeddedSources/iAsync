#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#ifdef __cplusplus
extern "C" {
#endif

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ );

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ );
JFFAsyncOperation serialAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ );

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
