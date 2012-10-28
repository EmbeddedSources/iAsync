#import "JFFCancelAsyncOperationBlockHolder.h"

@implementation JFFCancelAsyncOperationBlockHolder

- (void)performCancelBlockOnceWithArgument:(BOOL)cancel
{
    if (!self.cancelBlock)
        return;
    
    JFFCancelAsyncOperation block = self.cancelBlock;
    self.cancelBlock = nil;
    block(cancel);
}

- (JFFCancelAsyncOperation)onceCancelBlock
{
    return ^void(BOOL cancel) {
        [self performCancelBlockOnceWithArgument:cancel];
    };
}

@end
