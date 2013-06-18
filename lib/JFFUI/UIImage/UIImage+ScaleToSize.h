#import <UIKit/UIKit.h>

@interface UIImage (ScaleToSize)

- (instancetype)imageScaledToSize:(CGSize)targetSize
                      contentMode:(UIViewContentMode)contentMode;

@end
