#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"
#import "JFFAsyncOperationAbstractFinishError.h"

@implementation NSObject (WeakAsyncOperation)

- (JFFAsyncOperation)autoUnsibscribeOrCancelAsyncOperation:(JFFAsyncOperation)nativeAsyncOp
                                                      task:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(nativeAsyncOp);
    
    __weak id weakSelf = self;
    
    nativeAsyncOp = [nativeAsyncOp copy];
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        id self_ = weakSelf;
        
        if (self_ == nil) {
            
            NSError *error = [JFFAsyncOperationAbstractFinishError newAsyncOperationAbstractFinishErrorWithHandlerTask:task];
            if (doneCallback)
                doneCallback(nil, error);
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        __block BOOL finished = NO;
        
        __block JFFSimpleBlock handlerHolder;
        
        JFFDidFinishAsyncOperationBlockHolder *doneCallbackHolder = [JFFDidFinishAsyncOperationBlockHolder new];
        doneCallbackHolder.didFinishBlock = doneCallback;
        JFFDidFinishAsyncOperationCallback doneCallbackWrapper = ^void(id result, NSError *error) {
            
            if (handlerHolder) {
                [weakSelf removeOnDeallocBlock:handlerHolder];
                handlerHolder = nil;
            }
            
            finished = YES;
            doneCallbackHolder.onceDidFinishBlock(result, error);
        };
        
        JFFAsyncOperationHandler loadersHandler = nativeAsyncOp(progressCallback,
                                                                stateCallback,
                                                                doneCallbackWrapper);
        
        if (finished) {
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        handlerHolder = ^void(void) {
            
            loadersHandler(task);
        };
        
        //try assert retain count
        [self_ addOnDeallocBlock:handlerHolder];
        
        __block JFFAsyncOperationHandler handlerBlockHolder = [^void(JFFAsyncOperationHandlerTask task) {
            loadersHandler(task);
        } copy];
        
        return ^(JFFAsyncOperationHandlerTask task) {
            
            JFFAsyncOperationHandler hadler = handlerBlockHolder;
            if (!hadler)
                return;
            
            if (task <= JFFAsyncOperationHandlerTaskCancel) {
                handlerBlockHolder = nil;
            }
            hadler(task);
        };
    };
}

- (JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:(JFFAsyncOperation)nativeLoader
{
    return [self autoUnsibscribeOrCancelAsyncOperation:nativeLoader
                                                  task:JFFAsyncOperationHandlerTaskUnSubscribe];
}

- (JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:(JFFAsyncOperation)nativeLoader
{
    return [self autoUnsibscribeOrCancelAsyncOperation:nativeLoader
                                                  task:JFFAsyncOperationHandlerTaskCancel];
}

@end
