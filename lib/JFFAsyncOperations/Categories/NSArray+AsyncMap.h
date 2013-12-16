#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSArray (AsyncMap)

- (JFFAsyncOperation)asyncMap:(JFFAsyncOperationBinder)block;

- (JFFAsyncOperation)asyncWaitAllMap:(JFFAsyncOperationBinder)block;

- (JFFAsyncOperation)tolerantFaultAsyncMap:(JFFAsyncOperationBinder)block;

@end
