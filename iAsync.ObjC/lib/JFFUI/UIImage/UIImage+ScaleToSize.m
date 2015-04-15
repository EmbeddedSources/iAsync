#import "UIImage+ScaleToSize.h"

@implementation UIImage (ScaleToSize)

- (UIImage *)imageScaledToSize:(CGSize)targetSize
                   contentMode:(UIViewContentMode)contentMode
{
    //other contentModes does not supported yet
    NSParameterAssert(UIViewContentModeScaleAspectFill == contentMode);
    
    CGSize originalSize = self.size;
    CGFloat scale = MAX(targetSize.width / originalSize.width, targetSize.height / originalSize.height);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = originalSize.width  * scale;
    thumbnailRect.size.height = originalSize.height * scale;
    
    UIGraphicsBeginImageContextWithOptions(thumbnailRect.size, YES, 0.0);
    
    [self drawInRect:thumbnailRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (newImage == nil) NSLog(@"could not scale image");
    
    return newImage;
}

- (instancetype)imageScale:(CGFloat)scale
{
    UIGraphicsBeginImageContext(self.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(currentContext, self.size.width/2.f, self.size.height/2.f);
    
    CGContextScaleCTM(currentContext, scale, -scale);
    
    CGRect drawRect = CGRectMake(-self.size.width/2.f, -self.size.height/2.f, self.size.width, self.size.height);
    CGContextDrawImage(currentContext, drawRect, self.CGImage);
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cropped;
}

@end
