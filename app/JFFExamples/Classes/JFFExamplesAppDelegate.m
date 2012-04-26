#import "JFFExamplesAppDelegate.h"

@implementation JFFExamplesAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tab_bar_controller;

#pragma mark -
#pragma mark Memory management

-(void)dealloc
{
   [ _tab_bar_controller release ];
   [ _window release ];

   [ super dealloc ];
}

#pragma mark -
#pragma mark Application lifecycle

-(BOOL)application:( UIApplication* )application_ didFinishLaunchingWithOptions:( NSDictionary* )launch_options_
{    
   // Override point for customization after app launch.

   // Set the tab bar controller as the window's root view controller and display.
   self.window.rootViewController = self.tabBarController;
   [ self.window makeKeyAndVisible ];

   return YES;
}

-(void)applicationWillResignActive:( UIApplication* )application
{
   /*
    Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    */
}

-(void)applicationDidBecomeActive:( UIApplication* )application_
{
   /*
    Restart any tasks that were paused (or not yet started) while the application was inactive.
    */
}

-(void)applicationWillTerminate:( UIApplication* )application_
{
   /*
    Called when the application is about to terminate.
    */
}

#pragma mark -
#pragma mark UITabBarControllerDelegate methods

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
 */

/*
 // Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
 */

@end
