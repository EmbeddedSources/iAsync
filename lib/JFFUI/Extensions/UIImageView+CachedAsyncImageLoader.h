#import <UIKit/UIKit.h>

#include <objc/runtime.h>

@interface UIImageView (CachedAsyncImageLoader)

- (void)setImageWithURL:(NSURL *)url andPlaceholder:(UIImage *)placeholder;

@end
