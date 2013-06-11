#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFAsyncOperationInterface;
typedef id<JFFAsyncOperationInterface> (^JFFAsyncOperationInstanceBuilder)(void);

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation buildAsyncOperationWithAdapterFactory(JFFAsyncOperationInstanceBuilder factory);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
