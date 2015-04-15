#import "JFFAlertView+Async.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFShowAlerLoader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFShowAlerLoader
{
@public
    JFFAlertView *_alertView;
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    if (!_alertView) {
        
        if (finishCallback)
            finishCallback(nil, [JFFAsyncOpFinishedByCancellationError new]);
        return;
    }
    
    _alertView.didDismissHandler = ^() {
        
        if (finishCallback)
            finishCallback([NSNull new], nil);
    };
    
    [_alertView show];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    if (task == JFFAsyncOperationHandlerTaskCancel)
        [_alertView forceDismiss];
}

@end

@implementation JFFAlertView (Async)

+ (JFFAsyncOperation)showAlerLoaderWithBuilder:(JFFAlertViewBuilder)builder
{
    NSParameterAssert(builder);
    builder = [builder copy];
    
    JFFAsyncOperationInstanceBuilder objectFactory = ^id<JFFAsyncOperationInterface>() {
        
        JFFAlertView *alertView = builder();
        
        NSParameterAssert([alertView isKindOfClass:[JFFAlertView class]]);
        
        JFFShowAlerLoader *loader = [JFFShowAlerLoader new];
        
        loader->_alertView = alertView;
        
        return loader;
    };
    return buildAsyncOperationWithAdapterFactory(objectFactory);
}

@end
