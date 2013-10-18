#import "JFFAlertView+Async.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@interface JFFShowAlerLoader : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFShowAlerLoader
{
@public
    JFFAlertView *_alertView;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    if (!_alertView) {
        
        if (cancelHandler)
            cancelHandler(YES);
        return;
    }
    
    _alertView.didDismissHandler = ^() {
        
        if (handler)
            handler([NSNull new], nil);
    };
    
    [_alertView show];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled)
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
