#import <UIKit/UIKit.h>

@interface UIImage (JpegPackImage)

- (void)jffJpegPackImageToDataFilePath:(NSString *)filePath
                           compression:(CGFloat)compression;

@end
