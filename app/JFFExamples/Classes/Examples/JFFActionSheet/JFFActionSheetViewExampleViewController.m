#import "JFFActionSheetViewExampleViewController.h"

#import <JFFUI/AlertView/JFFActionSheet.h>
#import <JFFUI/AlertView/JFFAlertButton.h>

static NSString* const cancel_button_title_ = @"cancel";
static NSString* const destructive_button_title_ = @"destructive";
static NSString* const button1_button_title_ = @"button1";
static NSString* const button2_button_title_ = @"button2";

@implementation JFFActionSheetViewExampleViewController

-(id)init
{
   self = [ super initWithNibName: @"JFFActionSheetViewExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"JFFActionSheet example";
   }

   return self;
}

+(id)jffActionSheetExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

-(void)showActionSheet1WithButton2:( BOOL )show_button2_
{
   JFFAlertButton* destructive_button_ = [ JFFAlertButton alertButton: destructive_button_title_
                                                               action: ^
   {
      NSLog( @"ActionSheet1 \"%@\" button selected", destructive_button_title_ );
   } ];

   JFFActionSheet* action_sheet_ = [ JFFActionSheet actionSheetWithTitle: @"ActionSheet1"
                                                       cancelButtonTitle: nil
                                                  destructiveButtonTitle: destructive_button_
                                                       otherButtonTitles: nil ];

   if ( show_button2_ )
   {
      [ action_sheet_ addActionButtonWithTitle: button2_button_title_
                                         ation: ^
      {
         NSLog( @"ActionSheet1 \"%@\" button selected", button2_button_title_ );
      } ];
   }
   [ action_sheet_ addActionButtonWithTitle: button1_button_title_
                                      ation: ^
   {
      NSLog( @"ActionSheet1 \"%@\" button selected", button1_button_title_ );
   } ];

   [ action_sheet_ addActionButtonWithTitle: cancel_button_title_
                                      ation: ^
   {
      NSLog( @"ActionSheet1 \"%@\" button selected", cancel_button_title_ );
   } ];
   action_sheet_.cancelButtonIndex = action_sheet_.numberOfButtons - 1;

   [ action_sheet_ showInView: [ [ UIApplication sharedApplication ] keyWindow ] ];
}

-(IBAction)showActionSheet1Action:( id )sender_
{
   [ self showActionSheet1WithButton2: NO ];
}

-(IBAction)showActionSheet2Action:( id )sender_
{
   [ self showActionSheet1WithButton2: YES ];
}

-(IBAction)showActionSheet3Action:( id )sender_
{
   JFFAlertButton* cancel_button_ = [ JFFAlertButton alertButton: cancel_button_title_
                                                          action: ^
   {
      NSLog( @"ActionSheet2 \"%@\" button selected", cancel_button_title_ );
   } ];

   JFFAlertButton* destructive_button_ = [ JFFAlertButton alertButton: destructive_button_title_
                                                               action: ^
   {
      NSLog( @"ActionSheet2 \"%@\" button selected", destructive_button_title_ );
   } ];

   JFFAlertButton* button1_button_ = [ JFFAlertButton alertButton: button1_button_title_
                                                           action: ^
   {
      NSLog( @"ActionSheet2 \"%@\" button selected", button1_button_title_ );
   } ];

   JFFActionSheet* action_sheet_ = [ JFFActionSheet actionSheetWithTitle: @"ActionSheet2"
                                                       cancelButtonTitle: cancel_button_
                                                  destructiveButtonTitle: destructive_button_
                                                       otherButtonTitles: button1_button_, nil ];

   [ action_sheet_ showInView: [ [ UIApplication sharedApplication ] keyWindow ] ];
}

@end
