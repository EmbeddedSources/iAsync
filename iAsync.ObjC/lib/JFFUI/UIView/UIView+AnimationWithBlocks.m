#import "UIView+AnimationWithBlocks.h"

static NSTimeInterval defaultAnimationDuration = 0.2;
static NSTimeInterval defaultAnimationDelay = 0.0;

@implementation UIView (AnimationWithBlocks)

+ (void)animateWithAnimations:(JFFSimpleBlock)animations
{
    [self animateWithDuration:defaultAnimationDuration
                   animations:animations];
}

+ (void)animateWithOptions:(UIViewAnimationOptions)options
                animations:(JFFSimpleBlock)animations
{
    [self animateWithOptions:options
                  animations:animations
                  completion:nil];
}

+ (void)animateWithOptions:(UIViewAnimationOptions)options
                animations:(JFFSimpleBlock)animations
                completion:(JFFCompletionBlock)completion
{
    [self animateWithDuration:defaultAnimationDuration
                        delay:defaultAnimationDelay
                      options:options
                   animations:animations
                   completion:completion];
}

@end
