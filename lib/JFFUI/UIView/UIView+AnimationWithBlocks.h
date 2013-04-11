#import <UIKit/UIView.h>

@interface UIView (AnimationWithBlocks)

//TODO add header for JFFSimpleBlocks
+ (void)animateWithAnimations:(JFFSimpleBlock)animations;

+ (void)animateWithOptions:(UIViewAnimationOptions )options
                animations:(JFFSimpleBlock)animations;

@end
