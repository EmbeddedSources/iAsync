#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSObject (WeakAsyncOperation)

//TODO20 immediately cancel callback
- (JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:(JFFAsyncOperation)asyncOp;

- (JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:(JFFAsyncOperation)asyncOp;

@end
