#import <UIKit/UIView.h>

@interface UIView (AnimationWithBlocks)

+ (void)animateWithAnimations:(JFFSimpleBlock)animations;

+ (void)animateWithOptions:(UIViewAnimationOptions )options
                animations:(JFFSimpleBlock)animations;

@end
