#import <UIKit/UIKit.h>

@interface UIImage (DrawImageInImage)

- (instancetype)drawInImage:(UIImage *)bgImage
                    atPoint:(CGPoint)point
                       size:(CGSize)size;

@end
