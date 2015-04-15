#import "UIImage+DrawImageInImage.h"

//source: http://stackoverflow.com/questions/7313023/overlay-an-image-over-another-image-in-ios

@implementation UIImage (DrawImageInImage)

- (instancetype)drawInImage:(UIImage *)bgImage
                    atPoint:(CGPoint)point
                       size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.f);
    
    [bgImage drawAsPatternInRect:CGRectMake(0.f, 0.f, size.width, size.height)];
    [self drawInRect:CGRectMake(point.x, point.y, self.size.width, self.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
