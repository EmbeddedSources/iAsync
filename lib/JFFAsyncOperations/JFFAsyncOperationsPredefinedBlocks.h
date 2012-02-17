#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

extern JFFCancelAsyncOperation JFFEmptyCancelAsyncOperationBlock;
extern JFFAsyncOperation JFFAsyncOperationBlockWithSuccessResult;

JFFAsyncOperation asyncOperationBlockWithSuccessResultAfterDelay( NSTimeInterval delay_ );
