#import "UIAlertViewExampleViewController.h"

static NSString* const cancel_button_title_ = @"cancel";
static NSString* const button1_button_title_ = @"button1";
static NSString* const button2_button_title_ = @"button2";

@interface UIAlertViewExampleViewController ()

@property ( nonatomic, retain ) UIAlertView* alertView1;
@property ( nonatomic, retain ) UIAlertView* alertView2;

@end

@implementation UIAlertViewExampleViewController

@synthesize alertView1 = _alert_view1;
@synthesize alertView2 = _alert_view2;

-(void)dealloc
{
   [ _alert_view1 release ];
   [ _alert_view2 release ];

   [ super dealloc ];
}

-(id)init
{
   self = [ super initWithNibName: @"UIAlertViewExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"UIAlertView example";
   }

   return self;
}

+(id)uiAlertViewExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
   return YES;
}

-(void)showAlertView1WithButton2:( BOOL )show_button2_
{
   self.alertView1 = [ [ [ UIAlertView alloc ] initWithTitle: @"Alert1"
                                                     message: @"test"
                                                    delegate: self
                                           cancelButtonTitle: cancel_button_title_
                                           otherButtonTitles: nil ] autorelease ];

   if ( show_button2_ )
   {
      [ self.alertView1 addButtonWithTitle: button2_button_title_ ];
   }
   [ self.alertView1 addButtonWithTitle: button1_button_title_ ];

   [ self.alertView1 show ];
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
   self.alertView2 = [ [ [ UIAlertView alloc ] initWithTitle: @"Alert2"
                                                     message: @"test"
                                                    delegate: self
                                           cancelButtonTitle: cancel_button_title_
                                           otherButtonTitles: button1_button_title_, nil ] autorelease ];

   [ self.alertView2 show ];
}

#pragma mark UIAlertViewDelegate

-(void)alertView:( UIAlertView* )alert_view_ clickedButtonAtIndex:( NSInteger )button_index_
{
   NSString* clicked_button_title_ = [ alert_view_ buttonTitleAtIndex: button_index_ ];

   if ( self.alertView1 == alert_view_ )
   {
      if ( [ clicked_button_title_ isEqualToString: cancel_button_title_ ] )
      {
         NSLog( @"Alert1 \"%@\" button selected with index: %d", cancel_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: button1_button_title_ ] )
      {
         NSLog( @"Alert1 \"%@\" button selected with index: %d", button1_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: button2_button_title_ ] )
      {
         NSLog( @"Alert1 \"%@\" button selected with index: %d", button2_button_title_, button_index_ );
      }
      self.alertView1 = nil;
   }
   else if ( self.alertView2 == alert_view_ )
   {
      if ( [ clicked_button_title_ isEqualToString: cancel_button_title_ ] )
      {
         NSLog( @"Alert2 \"%@\" button selected with index: %d", cancel_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: button1_button_title_ ] )
      {
         NSLog( @"Alert2 \"%@\" button selected with index: %d", button1_button_title_, button_index_ );
      }
      self.alertView2 = nil;
   }
}

@end
