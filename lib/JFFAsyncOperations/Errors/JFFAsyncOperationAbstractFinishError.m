#import "JFFAsyncOperationAbstractFinishError.h"

#import "JFFAsyncOpFinishedByCancellationError.h"
#import "JFFAsyncOpFinishedByUnsubscriptionError.h"

@implementation JFFAsyncOperationAbstractFinishError

+ (instancetype)newAsyncOperationAbstractFinishErrorWithHandlerTask:(JFFAsyncOperationHandlerTask)task
{
    if (task > JFFAsyncOperationHandlerTaskCancel)
        return nil;
    
    return (task == JFFAsyncOperationHandlerTaskCancel)
    ?[JFFAsyncOpFinishedByCancellationError   new]
    :[JFFAsyncOpFinishedByUnsubscriptionError new];
}

@end
