#import "UIView+AnimationWithBlocks.h"

static NSTimeInterval default_animation_duration_ = 0.2;
static NSTimeInterval default_animation_delay_ = 0.0;

@implementation UIView (AnimationWithBlocks)

+(void)animateWithAnimations:( void (^)( void ) )animations_
{
    [ self animateWithDuration: default_animation_duration_
                    animations: animations_ ];
}

+(void)animateWithOptions:( UIViewAnimationOptions )options_
               animations:( void (^)( void ) )animations_
{
    [ self animateWithDuration: default_animation_duration_
                         delay: default_animation_delay_
                       options: options_
                    animations: animations_
                    completion: nil ];
}

@end
