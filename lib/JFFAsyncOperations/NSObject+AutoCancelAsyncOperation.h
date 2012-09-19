#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSObject (WeakAsyncOperation)

- (JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:(JFFAsyncOperation)asyncOp;

- (JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:(JFFAsyncOperation)asyncOp;

@end
