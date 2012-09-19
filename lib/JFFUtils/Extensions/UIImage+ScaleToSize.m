#import "UIImage+ScaleToSize.h"

@implementation UIImage (ScaleToSize)

- (UIImage *)imageScaledToSize:(CGSize)targetSize
                   contentMode:(UIViewContentMode)contentMode
{
    //other contentModes does not supported yet
    NSParameterAssert(UIViewContentModeScaleAspectFill == contentMode);
    
    CGSize originalSize = self.size;
    CGFloat scale = MAX(targetSize.width / originalSize.width, targetSize.height / originalSize.height);
    
    UIGraphicsBeginImageContext(targetSize);
    
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = originalSize.width  * scale;
    thumbnailRect.size.height = originalSize.height * scale;
    
    [self drawInRect:thumbnailRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    return newImage;
}

@end
