#import <UIKit/UIKit.h>

typedef enum
{
    JFFPackImageResultFilePathDocuments,
    JFFPackImageResultFilePathCache
} JFFPackImageResultFilePathType;

@interface UIImage (JpegPackImage)

- (NSData *)jffJpegPackerImageData;

- (void)jffJpegPackImageToDataFilePath:(NSString *)filePath
                           compression:(CGFloat)compression;

@end
