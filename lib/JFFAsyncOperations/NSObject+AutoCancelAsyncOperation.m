#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation NSObject (WeakAsyncOperation)

- (JFFAsyncOperation)autoUnsibscribeOrCancelAsyncOperation:(JFFAsyncOperation)nativeAsyncOp
                                                    cancel:(BOOL)cancelNativeAsyncOp
{
    NSParameterAssert(nativeAsyncOp);
    
    __weak id weakSelf = self;
    
    nativeAsyncOp = [nativeAsyncOp copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        if (weakSelf == nil) {
            
            if (cancelCallback) {
                cancelCallback(cancelNativeAsyncOp);
            }
            return JFFStubCancelAsyncOperationBlock;
        }
        
        __block BOOL finished = NO;
        
        JFFSimpleBlockHolder *ondeallocBlockHolder = [JFFSimpleBlockHolder new];
        
        JFFSimpleBlockHolder *removeOndeallocBlockHolder = [JFFSimpleBlockHolder new];
        removeOndeallocBlockHolder.simpleBlock = ^void(void) {
            finished = YES;
            
            if (ondeallocBlockHolder.simpleBlock) {
                [weakSelf removeOnDeallocBlock:ondeallocBlockHolder.simpleBlock];
                ondeallocBlockHolder.simpleBlock = nil;
            }
        };
        
        __block JFFCancelAsyncOperation cancelCallbackHolder;
        cancelCallbackHolder = [cancelCallback copy];
        JFFCancelAsyncOperationHandler cancelCallbackWrapper = ^void(BOOL cancelOp) {
            removeOndeallocBlockHolder.onceSimpleBlock();
            if (cancelCallbackHolder) {
                cancelCallbackHolder(cancelOp);
                cancelCallbackHolder = nil;
            }
        };
        
        JFFDidFinishAsyncOperationBlockHolder *doneCallbackHolder = [JFFDidFinishAsyncOperationBlockHolder new];
        doneCallbackHolder.didFinishBlock = doneCallback;
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper = ^void(id result, NSError *error) {
            removeOndeallocBlockHolder.onceSimpleBlock();
            doneCallbackHolder.onceDidFinishBlock(result, error);
        };
        
        JFFCancelAsyncOperation cancel = nativeAsyncOp(progressCallback,
                                                       cancelCallbackWrapper,
                                                       doneCallbackWrapper);
        
        if (finished) {
            return JFFStubCancelAsyncOperationBlock;
        }

        //TODO remove using of ondealloc block holder class
        ondeallocBlockHolder.simpleBlock = ^void(void) {
            
            cancel(cancelNativeAsyncOp);
        };
        
        //try assert retain count
        [weakSelf addOnDeallocBlock:ondeallocBlockHolder.onceSimpleBlock];
        
        __block JFFCancelAsyncOperation cancelBlockHolder = [^void(BOOL canceled) {
            cancel(canceled);
        } copy];
        
        return ^(BOOL canceled) {
            JFFCancelAsyncOperation cancel = cancelBlockHolder;
            if (!cancel)
                return;
            cancelBlockHolder = nil;
            cancel(canceled);
        };
    };
}

- (JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:(JFFAsyncOperation)nativeLoader
{
    return [self autoUnsibscribeOrCancelAsyncOperation:nativeLoader
                                                 cancel:NO];
}

- (JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:(JFFAsyncOperation)nativeLoader
{
    return [self autoUnsibscribeOrCancelAsyncOperation:nativeLoader
                                                cancel:YES];
}

@end
