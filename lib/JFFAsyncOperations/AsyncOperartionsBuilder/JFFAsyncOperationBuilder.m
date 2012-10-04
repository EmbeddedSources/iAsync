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

//TODO use factory and test
JFFAsyncOperation buildAsyncOperationWithInterface(id< JFFAsyncOperationInterface >asyncObject)
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        __unsafe_unretained id< JFFAsyncOperationInterface > weakAsyncObject = asyncObject;
        
        doneCallback = [doneCallback copy];
        void (^completionHandler)(id, NSError*) = [^(id result, NSError *error) {
            //use asyncObject_ in if to own it while waiting result
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
        
        __block BOOL progressCallbackWasCalled = NO;
        
        void (^completionHandlerWrapper)(id, NSError *) = [^(id result,NSError *error) {
            if (!progressCallbackWasCalled && result && progressHandler) {
                progressHandler(result);
            }
            
            progressHandler = nil;
            [proxy notifyCallbackWithResult:result error:error];
            proxy = nil;
        } copy];

        void (^progressHandlerWrapper)(id) = [^(id data) {
            progressCallbackWasCalled = YES;
            if (progressHandler)
                progressHandler(data);
        }copy];
        
        [asyncObject asyncOperationWithResultHandler:completionHandlerWrapper
                                     progressHandler:progressHandlerWrapper];
        
        __block JFFCancelAsyncOperationHandler cancelCallbackHolder = [cancelCallback copy];
        return ^(BOOL canceled) {
            if (!proxy.completionHandler)
                return;
            
            [weakAsyncObject cancel:canceled];
            
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
