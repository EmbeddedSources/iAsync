#import <UIKit/UIKit.h>

@interface UIImageView (CachedAsyncImageLoader)

- (void)setImageWithURL:(NSURL *)url andPlaceholder:(UIImage *)placeholder;

@end
