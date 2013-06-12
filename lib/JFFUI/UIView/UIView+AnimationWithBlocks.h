#import <UIKit/UIView.h>

typedef void(^JFFCompletionBlock)(BOOL finished);

@interface UIView (AnimationWithBlocks)

//TODO add header for JFFSimpleBlocks
+ (void)animateWithAnimations:(JFFSimpleBlock)animations;

+ (void)animateWithOptions:(UIViewAnimationOptions )options
                animations:(JFFSimpleBlock)animations;

+ (void)animateWithOptions:(UIViewAnimationOptions )options
                animations:(JFFSimpleBlock)animations
                completion:(JFFCompletionBlock)completion;

@end
