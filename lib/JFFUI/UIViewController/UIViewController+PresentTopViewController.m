#import "UIViewController+PresentTopViewController.h"

@implementation UIViewController (PresentTopViewController)

-(void)presentTopViewController:( UIViewController* )viewControllerToPresent_
                       animated:( BOOL )flag_
                     completion:( void (^)(void) )completion_
{
    UIViewController* presentingController_ = self.presentedViewController ?: self;
    [ presentingController_ presentViewController: viewControllerToPresent_
                                         animated: flag_
                                       completion: completion_ ];
}

-(void)presentTopViewController:( UIViewController* )viewControllerToPresent_
{
    [ self presentTopViewController: viewControllerToPresent_
                           animated: YES
                         completion: nil ];
}

@end
