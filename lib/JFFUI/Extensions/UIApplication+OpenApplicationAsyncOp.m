#import "UIApplication+OpenApplicationAsyncOp.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

static NSString *const delegateName = @"delegate";

@interface JFFOpenApplicationWithURLDelegateProxy : NSObject<
UIApplicationDelegate,
JFFAsyncOperationInterface
>

@property (nonatomic) NSURL         *url;
@property (nonatomic) UIApplication *application;

@end

@implementation JFFOpenApplicationWithURLDelegateProxy
{
    JFFAsyncOperationInterfaceHandler _handler;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    [self->_application addDelegateProxy:self delegateName:delegateName];

    self->_handler = [handler copy];

    [self->_application openURL: self->_url];
}

- (void)cancel:(BOOL)canceled
{
    [self->_application removeDelegateProxy:self delegateName:delegateName];
}

- (BOOL)finishWithURL:(NSURL *)url
{
    [self->_application removeDelegateProxy:self delegateName:delegateName];
    self->_handler(url, nil);

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self finishWithURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [self finishWithURL:url];
}

@end

@implementation UIApplication (OpenApplicationAsyncOp)

- (JFFAsyncOperation)asyncOperationWithApplicationURL:(NSURL *)url
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        JFFOpenApplicationWithURLDelegateProxy *proxy =
        [JFFOpenApplicationWithURLDelegateProxy new];

        proxy.url = url;
        proxy.application = self;

        return buildAsyncOperationWithInterface(proxy)(progressCallback, cancelCallback, doneCallback);
    };
}

@end
