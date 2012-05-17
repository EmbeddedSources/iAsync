#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFAsyncOperationInterface;

#ifdef __cplusplus
extern "C" {
#endif

JFFAsyncOperation buildAsyncOperationWithInterface( id< JFFAsyncOperationInterface > object_ );

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
