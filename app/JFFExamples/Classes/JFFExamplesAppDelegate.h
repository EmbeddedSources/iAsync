#import <UIKit/UIKit.h>

@interface JFFExamplesAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
{
@private
   UIWindow* _window;
   UITabBarController* _tab_bar_controller;
}

@property ( nonatomic, retain ) IBOutlet UIWindow* window;
@property ( nonatomic, retain ) IBOutlet UITabBarController* tabBarController;

@end
