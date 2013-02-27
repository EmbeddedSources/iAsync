#import "UIApplication+OpenApplicationAsyncOp.h"

#import "JFFOpenApplicationError.h"

#import <JFFScheduler/NSObject+Scheduler.h>
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
    JFFAsyncOperationInterfaceResultHandler _handler;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    [_application addDelegateProxy:self delegateName:delegateName];
    
    _handler = [handler copy];
    
    [_application openURL:_url];
}

- (void)cancel:(BOOL)canceled
{
    [_application removeDelegateProxy:self delegateName:delegateName];
}

- (BOOL)finishWithURL:(NSURL *)url
{
    [_application removeDelegateProxy:self delegateName:delegateName];
    
    if (url) {
        _handler(url, nil);
    } else {
        _handler(nil, [JFFOpenApplicationError new]);
    }
    
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

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self performSelector:@selector(finishWithURL:)
             timeInterval:.5
                 userInfo:nil
                  repeats:NO];
}

@end

@implementation UIApplication (OpenApplicationAsyncOp)

- (JFFAsyncOperation)asyncOperationWithApplicationURL:(NSURL *)url
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFOpenApplicationWithURLDelegateProxy *proxy =
        [JFFOpenApplicationWithURLDelegateProxy new];
        
        proxy.url = url;
        proxy.application = self;
        
        return proxy;
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}

@end
