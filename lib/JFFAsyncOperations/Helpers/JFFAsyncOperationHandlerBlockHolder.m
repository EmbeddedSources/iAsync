#import "JFFAsyncOperationHandlerBlockHolder.h"

@implementation JFFAsyncOperationHandlerBlockHolder

- (void)performCancelBlockOnceWithArgument:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (!_loaderHandler)
        return;
    
    JFFAsyncOperationHandler block = _loaderHandler;
    _loaderHandler = nil;
    block(task);
}

- (void)performHandlerWithArgument:(JFFAsyncOperationHandlerTask)task
{
    if (task <= JFFAsyncOperationHandlerTaskCancel)
        [self performCancelBlockOnceWithArgument:task];
    else
        _loaderHandler(task);
}

- (JFFAsyncOperationHandler)smartLoaderHandler
{
    return ^void(JFFAsyncOperationHandlerTask task) {
        
        [self performHandlerWithArgument:task];
    };
}

@end
