#ifndef JFFAsyncOperations_JFFAsyncOperationHandlerTask_h
#define JFFAsyncOperations_JFFAsyncOperationHandlerTask_h

typedef NS_ENUM(NSUInteger, JFFAsyncOperationHandlerTask)
{
    JFFAsyncOperationHandlerTaskUnSubscribe = 0,
    JFFAsyncOperationHandlerTaskCancel      = 1,
    JFFAsyncOperationHandlerTaskResume      = 2,
    JFFAsyncOperationHandlerTaskSuspend     = 3,
    JFFAsyncOperationHandlerTaskUndefined   = 4,
};

#endif //JFFAsyncOperations_JFFAsyncOperationHandlerTask_h
