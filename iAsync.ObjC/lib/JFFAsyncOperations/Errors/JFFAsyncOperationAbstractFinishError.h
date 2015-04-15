#import <JFFAsyncOperations/Errors/JFFAsyncOperationError.h>
#include <JFFAsyncOperations/JFFAsyncOperationHandlerTask.h>

@interface JFFAsyncOperationAbstractFinishError : JFFAsyncOperationError

+ (instancetype)newAsyncOperationAbstractFinishErrorWithHandlerTask:(JFFAsyncOperationHandlerTask)task;

@end
