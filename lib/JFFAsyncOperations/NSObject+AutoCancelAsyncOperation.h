#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:( JFFAsyncOperation )async_op_;

-(JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:( JFFAsyncOperation )async_op_;

@end
