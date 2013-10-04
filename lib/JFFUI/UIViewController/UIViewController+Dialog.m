#import "UIViewController+Dialog.h"

@implementation UIViewController (Dialog)

@dynamic onCompleteDialogBlock;

+ (void)load
{
    jClass_implementProperty(self, NSStringFromSelector(@selector(onCompleteDialogBlock)));
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
