#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationInterface.h"

@interface JFFComplitionHandlerNotifier : NSObject

@property (copy) JFFDidFinishAsyncOperationHandler completionHandler;

- (void)notifyCallbackWithResult:(id)result error:(NSError *)error;

@end

@implementation JFFComplitionHandlerNotifier

-(void)notifyCallbackWithResult:(id)result error:(NSError *)error
{
    if (self->_completionHandler) {
        self->_completionHandler(result, error);
        self->_completionHandler = nil;
    }
}

@end

//JTODO test
JFFAsyncOperation buildAsyncOperationWithAdapterFactory(JFFAsyncOperationInstanceBuilder factory)
{
    factory = [factory copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        id< JFFAsyncOperationInterface > asyncObject = factory();
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
        
        void (^completionHandlerWrapper)(id, NSError *) = [^(id result, NSError *error) {
            progressHandler = nil;
            [proxy notifyCallbackWithResult:result error:error];
            proxy = nil;
        } copy];
        
        void (^progressHandlerWrapper)(id) = [^(id data) {
            if (progressHandler)
                progressHandler(data);
        }copy];
        
        [asyncObject asyncOperationWithResultHandler:completionHandlerWrapper
                                     progressHandler:progressHandlerWrapper];
        
        __block JFFCancelAsyncOperationHandler cancelCallbackHolder = [cancelCallback copy];
        return ^(BOOL canceled) {
            if (!proxy.completionHandler)
                return;
            
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
