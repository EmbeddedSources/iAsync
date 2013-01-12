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
JFFAsyncOperation buildAsyncOperationWithAdapterFactory(JFFAsyncOperationInstanceBuilder objectFactory)
{
    objectFactory = [objectFactory copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        id< JFFAsyncOperationInterface > asyncObject = objectFactory();
        __unsafe_unretained id< JFFAsyncOperationInterface > unretaintedAsyncObject = asyncObject;
        
        doneCallback = [doneCallback copy];
        void (^completionHandler)(id, NSError*) = [^(id result, NSError *error) {
            //use asyncObject in if to own it while waiting result
            if (doneCallback && asyncObject)
                doneCallback(result, error);
        } copy];
        progressCallback = [progressCallback copy];
        __block void (^progressHandler)(id) = [^(id data) {
            if (progressCallback)
                progressCallback(data);
        } copy];
        
        completionHandler = [completionHandler copy];
        JFFObjectFactory factory = ^id() {
            JFFComplitionHandlerNotifier *result = [JFFComplitionHandlerNotifier new];
            result.completionHandler = completionHandler;
            return result;
        };
        
        __block JFFComplitionHandlerNotifier* proxy = (JFFComplitionHandlerNotifier*)
            [JFFSingleThreadProxy singleThreadProxyWithTargetFactory:factory
                                                       dispatchQueue:dispatch_get_current_queue()];
        
        __block JFFCancelAsyncOperationHandler cancelCallbackHolder = [cancelCallback copy];
        
        void (^completionHandlerWrapper)(id, NSError *) = [^(id result, NSError *error) {
            
            JFFComplitionHandlerNotifier* proxyOwner = proxy;
            proxy = nil;
            progressHandler = nil;
            cancelCallbackHolder = nil;//TODO what about other thread?
            [proxyOwner notifyCallbackWithResult:result error:error];
        } copy];
        
        void (^progressHandlerWrapper)(id) = [^(id data) {
            if (progressHandler)
                progressHandler(data);
        } copy];
        
        [asyncObject asyncOperationWithResultHandler:completionHandlerWrapper
                                     progressHandler:progressHandlerWrapper];
        
        return ^(BOOL canceled) {
            if (!proxy.completionHandler) {
                return;
            }
            
            [unretaintedAsyncObject cancel:canceled];
            
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
