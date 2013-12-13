#import "JFFAsyncOperationBuilder.h"

#import "JFFAsyncOperationInterface.h"
#import "JFFAsyncOperationAbstractFinishError.h"

//JTODO test
JFFAsyncOperation buildAsyncOperationWithAdapterFactoryWithDispatchQueue(JFFAsyncOperationInstanceBuilder objectFactory,
                                                                         dispatch_queue_t callbacksQueue)
{
    objectFactory = [objectFactory copy];
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        __block id<JFFAsyncOperationInterface> asyncObject = objectFactory();
        __unsafe_unretained id<JFFAsyncOperationInterface> unretaintedAsyncObject = asyncObject;
        
        doneCallback  = [doneCallback  copy];
        stateCallback = [stateCallback copy];
        
        __block void (^progressCallbackHolder)(id) = [progressCallback copy];
        
        __block JFFDidFinishAsyncOperationCallback finishCallbackHolder = [^(id result, NSError *error) {
            //use asyncObject in if to own it while waiting result
            
            if (!asyncObject)
                return;
            
            if (doneCallback)
                doneCallback(result, error);
            
            asyncObject = nil;
        } copy];
        
        __block BOOL stateCallbackCalled = NO;
        
        __block JFFAsyncOperationChangeStateCallback stateCallbackHolder = ^(JFFAsyncOperationState state) {
            
            stateCallbackCalled = YES;
            if (stateCallback)
                stateCallback(state);
        };
        
        NSThread *currntThread = [NSThread currentThread];
        
        void (^completionHandler)(id, NSError *) = ^(id result, NSError *error) {
            
            JFFDidFinishAsyncOperationCallback finishCallbackHolderTmp = finishCallbackHolder;
            finishCallbackHolder   = nil;
            progressCallbackHolder = nil;
            stateCallbackHolder    = nil;
            
            if (finishCallbackHolderTmp)
                finishCallbackHolderTmp(result, error);
        };
        
        void (^completionHandlerWrapper)(id, NSError *) = [^(id result, NSError *error) {
            
            if (!asyncObject)
                return;
            
            if ([asyncObject respondsToSelector:@selector(isForeignThreadResultCallback)]
                && [asyncObject isForeignThreadResultCallback]) {
                
                dispatch_async(callbacksQueue, ^() {
                    
                    completionHandler(result, error);
                });
            } else {
                
                if (dispatch_get_main_queue() == callbacksQueue) {
                    NSCAssert(currntThread == [NSThread currentThread], @"the same thread expected");
                }
                completionHandler(result, error);
            }
        } copy];
        
        void (^progressHandlerWrapper)(id) = [^(id data) {
            if (progressCallbackHolder)
                progressCallbackHolder(data);
        } copy];
        
        JFFAsyncOperationChangeStateCallback handlerCallbackWrapper = ^(JFFAsyncOperationState state) {
            
            if (!finishCallbackHolder)
                return;
            
            if (stateCallbackHolder)
                stateCallbackHolder(state);
        };
        
        [asyncObject asyncOperationWithResultCallback:completionHandlerWrapper
                                      handlerCallback:handlerCallbackWrapper
                                     progressCallback:progressHandlerWrapper];
        
        return ^(JFFAsyncOperationHandlerTask task) {
            
            if (!finishCallbackHolder) {
                return;
            }
            
            if ([unretaintedAsyncObject respondsToSelector:@selector(doTask:)]) {
                
                stateCallbackCalled = NO;
                [unretaintedAsyncObject doTask:task];
            } else {
                
                NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
            }
            
            NSError *error = [JFFAsyncOperationAbstractFinishError newAsyncOperationAbstractFinishErrorWithHandlerTask:task];
            
            if (error) {
                completionHandler(nil, error);
                return;
            } else {
                
                if (!stateCallbackCalled) {
                    
                    if (stateCallbackHolder) {
                        
                        JFFAsyncOperationState state = (task == JFFAsyncOperationHandlerTaskResume)
                        ?JFFAsyncOperationStateResumed
                        :JFFAsyncOperationStateSuspended;
                        stateCallbackHolder(state);
                    }
                }
            }
        };
    };
}

JFFAsyncOperation buildAsyncOperationWithAdapterFactory(JFFAsyncOperationInstanceBuilder factory)
{
    NSCAssert([NSThread isMainThread], @"main thread expected");
    return buildAsyncOperationWithAdapterFactoryWithDispatchQueue(factory, dispatch_get_main_queue());
}
