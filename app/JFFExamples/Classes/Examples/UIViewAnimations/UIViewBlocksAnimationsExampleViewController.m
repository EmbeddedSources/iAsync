#import "UIViewBlocksAnimationsExampleViewController.h"

#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>
#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFAsyncOperations/JFFAsyncOperationLogic.h>

static const CGFloat button_offset_ = 20.f;

@interface UIViewBlocksAnimationsExampleViewController ()
@end

@implementation UIViewBlocksAnimationsExampleViewController

@synthesize animatedButton;

-(id)init
{
   self = [ super initWithNibName: @"UIViewBlocksAnimationsExampleViewController" bundle: nil ];

   if ( self )
   {
      self.title = @"UIView blocks animations";
   }

   return self;
}

+(id)uiViewBlocksAnimationsExampleViewController
{
   return [ [ [ self alloc ] init ] autorelease ];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
	return YES;
}

-(JFFSimpleBlock)moveUpAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_y_ = self.animatedButton.frame.origin.y
         - ( self.view.frame.size.height - button_offset_ * 2 )
         + self.animatedButton.frame.size.height;
      self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                             , new_y_
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)moveDownAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_y_ = self.animatedButton.frame.origin.y
         + ( self.view.frame.size.height - button_offset_ * 2 )
         - self.animatedButton.frame.size.height;
      self.animatedButton.frame = CGRectMake( self.animatedButton.frame.origin.x
                                             , new_y_
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)moveRightAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_x_ = self.animatedButton.frame.origin.x
         + ( self.view.frame.size.width - button_offset_ * 2 )
         - self.animatedButton.frame.size.width;
      self.animatedButton.frame = CGRectMake( new_x_
                                             , self.animatedButton.frame.origin.y
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFSimpleBlock)moveLeftAnimationBlock
{
   return [ [ ^
   {
      CGFloat new_x_ = self.animatedButton.frame.origin.x
         - ( self.view.frame.size.width - button_offset_ * 2 )
         + self.animatedButton.frame.size.width;
      self.animatedButton.frame = CGRectMake( new_x_
                                             , self.animatedButton.frame.origin.y
                                             , self.animatedButton.frame.size.width
                                             , self.animatedButton.frame.size.height );
   } copy ] autorelease ];
}

-(JFFAsyncOperation)animationBlockWithAnimations:( JFFSimpleBlock )animations_
{
   return [ [ ^( JFFAsyncOperationProgressHandler progress_callback_
                , JFFCancelHandler cancel_callback_
                , JFFDidFinishAsyncOperationHandler done_callback_ )
   {
      done_callback_ = [ [ done_callback_ copy ] autorelease ];
      [ UIView animateWithDuration: 0.2
                        animations: animations_
                        completion: ^( BOOL finished_ )
      {
         if ( done_callback_ )
            done_callback_( [ NSNull null ], nil );
      } ];
      return [ [ ^{} copy ] autorelease ];
   } copy ] autorelease ];
}

-(IBAction)animateButtonAction:( id )sender_
{
   JFFSimpleBlock move_right_animation_block_ = [ self moveRightAnimationBlock ];
   JFFAsyncOperation move_right_async_block_ = [ self animationBlockWithAnimations: move_right_animation_block_ ];

   JFFSimpleBlock move_up_animation_block_ = [ self moveUpAnimationBlock ];
   JFFAsyncOperation move_up_async_block_ = [ self animationBlockWithAnimations: move_up_animation_block_ ];

   JFFSimpleBlock move_left_animation_block_ = [ self moveLeftAnimationBlock ];
   JFFAsyncOperation move_left_async_block_ = [ self animationBlockWithAnimations: move_left_animation_block_ ];

   JFFSimpleBlock move_down_animation_block_ = [ self moveDownAnimationBlock ];
   JFFAsyncOperation move_down_async_block_ = [ self animationBlockWithAnimations: move_down_animation_block_ ];

   JFFAsyncOperation result_animation_block_ = sequenceOfAsyncOperations(
                                                                         move_right_async_block_
                                                                         , move_up_async_block_
                                                                         , move_left_async_block_
                                                                         , move_down_async_block_
                                                                         , nil );

   result_animation_block_( nil, nil, nil );
}

@end
