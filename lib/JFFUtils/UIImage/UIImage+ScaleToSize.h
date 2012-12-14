#import <UIKit/UIKit.h>

@interface UIImage (ScaleToSize)

- (UIImage *)imageScaledToSize:(CGSize)targetSize
                   contentMode:(UIViewContentMode)contentMode;

@end
