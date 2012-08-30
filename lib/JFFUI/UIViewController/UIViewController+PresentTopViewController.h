#import <UIKit/UIKit.h>

@interface UIViewController (PresentTopViewController)

-(void)presentTopViewController:( UIViewController* )viewControllerToPresent_;

-(void)presentTopViewController:( UIViewController* )viewControllerToPresent_
                       animated:( BOOL )flag_
                     completion:( void (^)(void) )completion_;

@end
