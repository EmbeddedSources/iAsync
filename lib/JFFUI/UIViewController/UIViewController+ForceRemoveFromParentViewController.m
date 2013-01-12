#import "UIViewController+ForceRemoveFromParentViewController.h"

@implementation UIViewController (ForceRemoveFromParentViewController)

- (void)forceRemoveFromParentViewController
{
    if (self.isViewLoaded && self.view.superview) {
        
        [self.view removeFromSuperview];
    }
    
    if (self.parentViewController)
        [self removeFromParentViewController];
}

@end
