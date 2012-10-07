#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFAsyncOperationInterface;
typedef id< JFFAsyncOperationInterface >(^JFFAsyncOperationInstanceBuilder)(void);

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation buildAsyncOperationWithInterface(JFFAsyncOperationInstanceBuilder builder);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
