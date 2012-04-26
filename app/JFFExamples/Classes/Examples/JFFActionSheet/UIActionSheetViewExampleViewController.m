#import "UIActionSheetViewExampleViewController.h"

static NSString* const cancel_button_title_ = @"cancel";
static NSString* const destructive_button_title_ = @"destructive";
static NSString* const button1_button_title_ = @"button1";
static NSString* const button2_button_title_ = @"button2";

@interface UIActionSheetViewExampleViewController () < UIActionSheetDelegate >

@property ( nonatomic, retain ) UIActionSheet* actionSheet1;
@property ( nonatomic, retain ) UIActionSheet* actionSheet2;

@end

@implementation UIActionSheetViewExampleViewController

@synthesize actionSheet1 = _action_sheet1;
@synthesize actionSheet2 = _action_sheet2;

-(void)dealloc
{
   [ _action_sheet1 release ];
   [ _action_sheet2 release ];

   [ super dealloc ];
}

-(id)init
{
   self = [ super initWithNibName: @"UIActionSheetViewExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"UIActionSheet example";
   }

   return self;
}

+(id)uiActionSheetExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

-(void)showActionSheet1WithButton2:( BOOL )show_button2_
{
   self.actionSheet1 = [ [ [ UIActionSheet alloc ] initWithTitle: @"ActionSheet1"
                                                        delegate: self
                                               cancelButtonTitle: nil
                                          destructiveButtonTitle: destructive_button_title_
                                               otherButtonTitles: nil ] autorelease ];

   if ( show_button2_ )
   {
      [ self.actionSheet1 addButtonWithTitle: button2_button_title_ ];
   }
   [ self.actionSheet1 addButtonWithTitle: button1_button_title_ ];

   if ( cancel_button_title_ )
   {
      [ self.actionSheet1 addButtonWithTitle: cancel_button_title_ ];
      self.actionSheet1.cancelButtonIndex = self.actionSheet1.numberOfButtons - 1;
   }

   [ self.actionSheet1 showInView: [ [ UIApplication sharedApplication ] keyWindow ] ];
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
   self.actionSheet2 = [ [ [ UIActionSheet alloc ] initWithTitle: @"ActionSheet2"
                                                        delegate: self
                                               cancelButtonTitle: cancel_button_title_
                                          destructiveButtonTitle: destructive_button_title_
                                               otherButtonTitles: button1_button_title_, nil ] autorelease ];

   [ self.actionSheet2 showInView: [ [ UIApplication sharedApplication ] keyWindow ] ];
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:( UIActionSheet* )action_sheet_ clickedButtonAtIndex:( NSInteger )button_index_
{
   NSString* clicked_button_title_ = [ action_sheet_ buttonTitleAtIndex: button_index_ ];

   if ( self.actionSheet1 == action_sheet_ )
   {
      if ( [ clicked_button_title_ isEqualToString: cancel_button_title_ ] )
      {
         NSLog( @"ActionSheet1 \"%@\" button selected with index: %d", cancel_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: destructive_button_title_ ] )
      {
         NSLog( @"ActionSheet1 \"%@\" button selected with index: %d", destructive_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: button1_button_title_ ] )
      {
         NSLog( @"ActionSheet1 \"%@\" button selected with index: %d", button1_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: button2_button_title_ ] )
      {
         NSLog( @"ActionSheet1 \"%@\" button selected with index: %d", button2_button_title_, button_index_ );
      }
      self.actionSheet1 = nil;
   }
   else if ( self.actionSheet2 == action_sheet_ )
   {
      if ( [ clicked_button_title_ isEqualToString: cancel_button_title_ ] )
      {
         NSLog( @"ActionSheet2 \"%@\" button selected with index: %d", cancel_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: destructive_button_title_ ] )
      {
         NSLog( @"ActionSheet2 \"%@\" button selected with index: %d", destructive_button_title_, button_index_ );
      }
      else if ( [ clicked_button_title_ isEqualToString: button1_button_title_ ] )
      {
         NSLog( @"ActionSheet2 \"%@\" button selected with index: %d", button1_button_title_, button_index_ );
      }
      self.actionSheet2 = nil;
   }
}

@end
