#import "UIImage+WriteToTmpFile.h"

#import "NSString+UUIDCreation.h"
#import "NSString+PathExtensions.h"

@implementation UIImage (WriteToTmpFile)

- (NSString *)writeToTmpFile
{
    NSData *data = UIImagePNGRepresentation(self);
    
    NSString *filePath = [NSString createUuid];
    filePath = [NSString cachesPathByAppendingPathComponent:filePath];
    
    [data writeToFile:filePath atomically:NO];
    
    return filePath;
}

@end
