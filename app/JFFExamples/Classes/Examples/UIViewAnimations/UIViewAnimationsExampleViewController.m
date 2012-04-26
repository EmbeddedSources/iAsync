#import "UIViewAnimationsExampleViewController.h"

static const CGFloat button_offset_ = 20.f;

@interface UIViewAnimationsExampleViewController ()
@end

@interface JFFNextAnimation : NSObject

@property ( nonatomic, retain ) UIViewAnimationsExampleViewController* controller;
@property ( nonatomic, retain ) NSMutableArray* nextAnimations;

@end

@implementation JFFNextAnimation

@synthesize controller;
@synthesize nextAnimations;

-(void)dealloc
{
   [ controller release ];
   [ nextAnimations release ];

   [ super dealloc ];
}

@end

@implementation UIViewAnimationsExampleViewController

@synthesize animatedButton;

-(id)init
{
   self = [ super initWithNibName: @"UIViewAnimationsExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"UIView animations";
   }

   return self;
}

+(id)uiViewAnimationsExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

-(void)moveUpAnimationWithNextAnimation:( JFFNextAnimation* )next_animation_
{
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_y_ = self.animatedButton.frame.origin.y
      - ( self.view.frame.size.height - button_offset_ * 2 )
      + self.animatedButton.frame.size.height;
   self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                          , new_y_
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(void)moveDownAnimationWithNextAnimation:( JFFNextAnimation* )next_animation_
{
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_y_ = self.animatedButton.frame.origin.y
      + ( self.view.frame.size.height - button_offset_ * 2 )
      - self.animatedButton.frame.size.height;
   self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                          , new_y_
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(void)moveRightAnimationWithNextAnimation:( JFFNextAnimation* )next_animation_
{
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_x_ = self.animatedButton.frame.origin.x
      + ( self.view.frame.size.width - button_offset_ * 2 )
      - self.animatedButton.frame.size.width;
   self.animatedButton.frame = CGRectMake( new_x_
                                          , self.animatedButton.frame.origin.y
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(void)moveLeftAnimationWithNextAnimation:( JFFNextAnimation* )next_animation_
{
   [ UIView beginAnimations: nil context: next_animation_ ];

   CGFloat new_x_ = self.animatedButton.frame.origin.x
      - ( self.view.frame.size.width - button_offset_ * 2 )
      + self.animatedButton.frame.size.width;
   self.animatedButton.frame = CGRectMake( new_x_
                                          , self.animatedButton.frame.origin.y
                                          , self.animatedButton.frame.size.width
                                          , self.animatedButton.frame.size.height );

   [ UIView setAnimationDelegate: self ];

   [ UIView commitAnimations ];
}

-(IBAction)animateButtonAction:( id )sender_
{
   JFFNextAnimation* next_animation_ = [ JFFNextAnimation new ];
   next_animation_.controller = self;
   next_animation_.nextAnimations = [ NSMutableArray arrayWithObjects:
                                     @"moveUpAnimationWithNextAnimation:"
                                     , @"moveLeftAnimationWithNextAnimation:"
                                     , @"moveDownAnimationWithNextAnimation:"
                                     , nil ];

   [ self moveRightAnimationWithNextAnimation: next_animation_ ];
}

-(void)animationDidStop:( NSString* )animation_id_ finished:( NSNumber* )finished_ context:( void* )context_
{
   if ( !context_ )
      return;

   JFFNextAnimation* context_object_ = context_;

   NSString* next_animation_string_ = [ context_object_.nextAnimations objectAtIndex: 0 ];
   next_animation_string_ = [ [ next_animation_string_ retain ] autorelease ];
   [ context_object_.nextAnimations removeObjectAtIndex: 0 ];

   SEL next_animation_sel_ = NSSelectorFromString( next_animation_string_ );

   if ( [ context_object_.nextAnimations count ] == 0 )
   {
      [ context_object_.controller performSelector: next_animation_sel_
                                        withObject: nil ];
      [ context_object_ release ];
   }
   else
   {
      [ context_object_.controller performSelector: next_animation_sel_
                                        withObject: context_object_ ];
   }
}

@end
