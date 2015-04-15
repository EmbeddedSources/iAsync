#import <UIKit/UIKit.h>

@interface UIImage (ScaleToSize)

- (instancetype)imageScaledToSize:(CGSize)targetSize
                      contentMode:(UIViewContentMode)contentMode;

- (instancetype)imageScale:(CGFloat)scale;

@end
