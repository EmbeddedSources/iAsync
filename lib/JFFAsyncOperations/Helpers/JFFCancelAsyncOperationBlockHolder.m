#import "JFFCancelAsyncOperationBlockHolder.h"

@implementation JFFCancelAsyncOperationBlockHolder

- (void)performCancelBlockOnceWithArgument:(BOOL)cancel
{
    if (!_cancelBlock)
        return;
    
    JFFCancelAsyncOperation block = _cancelBlock;
    _cancelBlock = nil;
    block(cancel);
}

- (JFFCancelAsyncOperation)onceCancelBlock
{
    return ^void(BOOL cancel) {
        [self performCancelBlockOnceWithArgument:cancel];
    };
}

@end
