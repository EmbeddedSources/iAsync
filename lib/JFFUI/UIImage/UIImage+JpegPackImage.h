#import <UIKit/UIKit.h>

@interface UIImage (JpegPackImage)

- (NSData *)jffJpegPackerImageData;

- (void)jffJpegPackImageToDataFilePath:(NSString *)filePath
                           compression:(CGFloat)compression;

@end
