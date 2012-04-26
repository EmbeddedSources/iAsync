#import "JFFAlertViewExampleViewController.h"

#import <JFFUI/AlertView/JFFAlertView.h>
#import <JFFUI/AlertView/JFFAlertButton.h>

static NSString* const cancel_button_title_ = @"cancel";
static NSString* const button1_button_title_ = @"button1";
static NSString* const button2_button_title_ = @"button2";

@implementation JFFAlertViewExampleViewController

-(id)init
{
   self = [ super initWithNibName: @"JFFAlertViewExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"JFFAlertView example";
   }

   return self;
}

+(id)jffAlertViewExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
   return YES;
}

-(void)showAlertView1WithButton2:( BOOL )show_button2_
{
   JFFAlertButton* cancel_button_ = [ JFFAlertButton alertButton: cancel_button_title_
                                                          action: ^
   {
      NSLog( @"Alert1 \"%@\" button selected", cancel_button_title_ );
   } ];

   JFFAlertView* alert_view_ = [ JFFAlertView alertWithTitle: @"Alert1"
                                                     message: @"test"
                                           cancelButtonTitle: cancel_button_
                                           otherButtonTitles: nil ];

   if ( show_button2_ )
   {
      [ alert_view_ addAlertButtonWithTitle: button2_button_title_
                                      ation: ^
      {
         NSLog( @"Alert1 \"%@\" button selected", button2_button_title_ );
      } ];
   }
   [ alert_view_ addAlertButtonWithTitle: button1_button_title_
                                   ation: ^
   {
      NSLog( @"Alert1 \"%@\" button selected", button1_button_title_ );
   } ];

   [ alert_view_ show ];
}

-(IBAction)showAlertView1Action:( id )sender_
{
   [ self showAlertView1WithButton2: NO ];
}

-(IBAction)showAlertView2Action:( id )sender_
{
   [ self showAlertView1WithButton2: YES ];
}

-(IBAction)showAlertView3Action:( id )sender_
{
   JFFAlertButton* cancel_button_ = [ JFFAlertButton alertButton: cancel_button_title_
                                                          action: ^
   {
      NSLog( @"Alert2 \"%@\" button selected", cancel_button_title_ );
   } ];

   JFFAlertButton* button1_ = [ JFFAlertButton alertButton: button1_button_title_
                                                    action: ^
   {
      NSLog( @"Alert2 \"%@\" button selected", button1_button_title_ );
   } ];

   JFFAlertView* alert_view_ = [ JFFAlertView alertWithTitle: @"Alert2"
                                                     message: @"test"
                                           cancelButtonTitle: cancel_button_
                                           otherButtonTitles: button1_, nil ];

   [ alert_view_ show ];
}

@end
