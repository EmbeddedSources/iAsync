#import "UIViewController+Dialog.h"

#import <objc/runtime.h>

static char __onCompleteDialogBlock;

@implementation UIViewController (Dialog)

- (void)setOnCompleteDialogBlock:(JFFCompleteDialogCallbackBlock)onCompleteDialogBlock
{
    objc_setAssociatedObject(self, &__onCompleteDialogBlock, onCompleteDialogBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (JFFCompleteDialogCallbackBlock)onCompleteDialogBlock
{
    return objc_getAssociatedObject(self, &__onCompleteDialogBlock);
}

#pragma mark -

- (void)completeDialogWithError:(NSError *)error
{
    [self completeDialogWithResult:nil error:error isCanceled:NO];
}

- (void)completeDialogWithResult:(id)result
{
    [self completeDialogWithResult:result error:nil isCanceled:NO];
}

- (void)cancelDialog
{
    [self completeDialogWithResult:nil error:nil isCanceled:YES];
}

- (void)completeDialogWithResult:(id)result error:(NSError *)error isCanceled:(BOOL)isCancaled
{
    JFFCompleteDialogCallbackBlock onCompleteDialogBlock = self.onCompleteDialogBlock;
    if (onCompleteDialogBlock) {
        onCompleteDialogBlock(result, error, isCancaled);
    }
}

@end
