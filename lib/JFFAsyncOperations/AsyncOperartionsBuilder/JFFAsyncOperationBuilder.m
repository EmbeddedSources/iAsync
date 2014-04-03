#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationInterface.h"

@interface JFFComplitionHandlerNotifier : NSObject

@property (copy) JFFDidFinishAsyncOperationHandler completionHandler;

- (void)notifyCallbackWithResult:(id)result error:(NSError *)error;

@end

@implementation JFFComplitionHandlerNotifier

- (void)notifyCallbackWithResult:(id)result error:(NSError *)error
{
    if (_completionHandler) {
        _completionHandler(result, error);
        _completionHandler = nil;
    }
}

@end

//JTODO test
JFFAsyncOperation buildAsyncOperationWithAdapterFactoryWithDispatchQueue(JFFAsyncOperationInstanceBuilder objectFactory,
                                                                         dispatch_queue_t callbacksQueue)
{
    objectFactory = [objectFactory copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        __block id<JFFAsyncOperationInterface> asyncObject = objectFactory();
        __weak id<JFFAsyncOperationInterface> unretaintedAsyncObject = asyncObject;
        
        doneCallback = [doneCallback copy];
        void (^completionHandler)(id, NSError*) = [^(id result, NSError *error) {
            //use asyncObject in if to own it while waiting result
            
            if (!asyncObject)
                return;
            
            if (doneCallback) {
                doneCallback(result, error);
            }
            
            asyncObject = nil;
        } copy];
        progressCallback = [progressCallback copy];
        __block void (^progressHandler)(id) = [^(id data) {
            if (progressCallback)
                progressCallback(data);
        } copy];
        
        completionHandler = [completionHandler copy];
        
        __block JFFComplitionHandlerNotifier *proxy = [JFFComplitionHandlerNotifier new];
        proxy.completionHandler = completionHandler;
        
        __block JFFCancelAsyncOperationHandler cancelCallbackHolder = [cancelCallback copy];
        
        NSThread *currntThread = [NSThread currentThread];
        
        void (^completionHandlerWrapper)(id, NSError *) = [^(id result, NSError *error) {
            
            if (!asyncObject)
                return;
            
            void (^completionHandler)(id, NSError *) = ^(id result, NSError *error) {
                JFFComplitionHandlerNotifier *proxyOwner = proxy;
                proxy                = nil;
                progressHandler      = nil;
                cancelCallbackHolder = nil;
                [proxyOwner notifyCallbackWithResult:result error:error];
            };
            
            if ([asyncObject respondsToSelector:@selector(isForeignThreadResultCallback)]
                && [asyncObject isForeignThreadResultCallback]) {
                
                dispatch_async(callbacksQueue, ^() {
                    
                    completionHandler(result, error);
                });
            } else {
                
                NSCAssert(currntThread == [NSThread currentThread], @"the same thread expected");
                completionHandler(result, error);
            }
        } copy];
        
        void (^progressHandlerWrapper)(id) = [^(id data) {
            if (progressHandler)
                progressHandler(data);
        } copy];
        
        JFFAsyncOperationInterfaceCancelHandler cancelHandlerWrapper = ^(BOOL canceled) {
            
            if (!proxy.completionHandler) {
                return;
            }
            
            proxy           = nil;
            progressHandler = nil;
            
            if (nil != cancelCallbackHolder) {
                JFFCancelAsyncOperationHandler tmpCallback = cancelCallbackHolder;
                cancelCallbackHolder = nil;
                tmpCallback(canceled);
            }
        };
        
        [asyncObject asyncOperationWithResultHandler:completionHandlerWrapper
                                       cancelHandler:cancelHandlerWrapper
                                     progressHandler:progressHandlerWrapper];
        
        return ^void(BOOL canceled) {
            
            if (!proxy.completionHandler) {
                return;
            }
            
            if ([unretaintedAsyncObject respondsToSelector:@selector(cancel:)]) {
                [unretaintedAsyncObject cancel:canceled];
            }
            
            proxy           = nil;
            progressHandler = nil;
            
            if (cancelCallbackHolder) {
                JFFCancelAsyncOperationHandler tmpCallback = cancelCallbackHolder;
                cancelCallbackHolder = nil;
                tmpCallback(canceled);
            }
        };
    };
}

JFFAsyncOperation buildAsyncOperationWithAdapterFactory(JFFAsyncOperationInstanceBuilder factory)
{
    NSCAssert([NSThread isMainThread], @"main thread expected");
    return buildAsyncOperationWithAdapterFactoryWithDispatchQueue(factory, dispatch_get_main_queue());
}
