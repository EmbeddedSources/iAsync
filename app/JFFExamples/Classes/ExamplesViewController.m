#import "ExamplesViewController.h"

#import "UIAlertViewExampleViewController.h"
#import "JFFAlertViewExampleViewController.h"

#import "UIActionSheetViewExampleViewController.h"
#import "JFFActionSheetViewExampleViewController.h"

#import "UIViewAnimationsExampleViewController.h"
#import "UIViewBlocksAnimationsExampleViewController.h"

@implementation ExamplesViewController

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
   return YES;
}

-(IBAction)showUIAlertViewExampleAction:( id )sender_
{
   UIViewController* controller_ = [ UIAlertViewExampleViewController uiAlertViewExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

-(IBAction)showJFFAlertViewExampleAction:( id )sender_
{
   UIViewController* controller_ = [ JFFAlertViewExampleViewController jffAlertViewExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

-(IBAction)showUIActionSheetExampleAction:( id )sender_
{
   UIViewController* controller_ = [ UIActionSheetViewExampleViewController uiActionSheetExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

-(IBAction)showJFFActionSheetExampleAction:( id )sender_
{
   UIViewController* controller_ = [ JFFActionSheetViewExampleViewController jffActionSheetExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

-(IBAction)showUIViewAnimationsAction:( id )sender_
{
   UIViewController* controller_ = [ UIViewAnimationsExampleViewController uiViewAnimationsExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

-(IBAction)showUIViewBlocksAnimationsAction:( id )sender_
{
   UIViewController* controller_ = [ UIViewBlocksAnimationsExampleViewController uiViewBlocksAnimationsExampleViewController ];
   [ self.navigationController pushViewController: controller_ animated: YES ];
}

@end
