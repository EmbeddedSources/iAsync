#import "UIApplication+OpenApplicationAsyncOp.h"

#import "JFFOpenApplicationError.h"

#import <JFFScheduler/NSObject+Timer.h>
#import <JFFAsyncOperations/JFFAsyncOperations.h>

static NSString *const delegateName = @"delegate";

@interface JFFOpenApplicationWithURLDelegateProxy : NSObject<
UIApplicationDelegate,
JFFAsyncOperationInterface
>

@end

@implementation JFFOpenApplicationWithURLDelegateProxy
{
    JFFDidFinishAsyncOperationCallback _finishCallback;
@public
    NSURL         *_url;
    UIApplication *_application;
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    [_application addDelegateProxy:self delegateName:delegateName];
    
    _finishCallback = [finishCallback copy];
    
    [_application openURL:_url];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    [_application removeDelegateProxy:self delegateName:delegateName];
}

- (BOOL)finishWithURL:(NSURL *)url
{
    [_application removeDelegateProxy:self delegateName:delegateName];
    
    if (url) {
        _finishCallback(url, nil);
    } else {
        _finishCallback(nil, [JFFOpenApplicationError new]);
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
                   leeway:.1
                 userInfo:nil
                  repeats:NO];
}

@end

@implementation UIApplication (OpenApplicationAsyncOp)

- (JFFAsyncOperation)asyncOperationWithApplicationURL:(NSURL *)url
{
    JFFAsyncOperationInstanceBuilder factory = ^id <JFFAsyncOperationInterface>(void) {
        
        JFFOpenApplicationWithURLDelegateProxy *proxy =
        [JFFOpenApplicationWithURLDelegateProxy new];
        
        proxy->_url = url;
        proxy->_application = self;
        
        return proxy;
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}

@end
