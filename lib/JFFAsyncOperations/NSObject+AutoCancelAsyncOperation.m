#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation NSObject (WeakAsyncOperation)

- (JFFAsyncOperation)autoUnsibscribeOrCancelAsyncOperation:(JFFAsyncOperation)nativeAsyncOp
                                                    cancel:(BOOL)cancelNativeAsyncOp
{
    NSParameterAssert(nativeAsyncOp);
    
    nativeAsyncOp = [nativeAsyncOp copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        __block BOOL finished = NO;
        __unsafe_unretained id weakSelf = self;
        
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
        
        ondeallocBlockHolder.simpleBlock = ^void(void) {
            cancel(cancelNativeAsyncOp);
        };
        
        //try assert retain count
        [self addOnDeallocBlock:ondeallocBlockHolder.simpleBlock];
        
        __block JFFCancelAsyncOperation cancelBlockHolder = [^void(BOOL canceled) {
            cancel(canceled);
        }copy];
        
        return ^(BOOL canceled) {
            if (!cancelBlockHolder)
                return;
            cancelBlockHolder(canceled);
            cancelBlockHolder = nil;
        };
    };
}

- (JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:(JFFAsyncOperation)nativeAsyncOp
{
    return [self autoUnsibscribeOrCancelAsyncOperation:nativeAsyncOp
                                                 cancel:NO];
}

- (JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:( JFFAsyncOperation )nativeAsyncOp
{
    return [self autoUnsibscribeOrCancelAsyncOperation:nativeAsyncOp
                                                cancel:YES];
}

@end
