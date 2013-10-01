#import "UIViewController+PresentTopViewController.h"

@implementation UIViewController (PresentTopViewController)

- (void)presentTopViewController:(UIViewController *)viewControllerToPresent
                        animated:(BOOL)flag
                      completion:(void (^)(void))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *presentingController = self.presentedViewController ?: self;
        [presentingController presentViewController:viewControllerToPresent
                                           animated:flag
                                         completion:completion];
    });
}

- (void)presentTopViewController:(UIViewController *)viewControllerToPresent
{
    [self presentTopViewController:viewControllerToPresent
                          animated:YES
                        completion:nil];
}

@end
