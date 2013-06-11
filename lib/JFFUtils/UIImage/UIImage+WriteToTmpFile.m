#import "UIImage+WriteToTmpFile.h"

#import "NSString+UUIDCreation.h"
#import "NSString+PathExtensions.h"

@implementation UIImage (WriteToTmpFile)

- (NSString *)writeToTmpFile
{
    //TODO refactor to use less memory
    NSData *data = UIImagePNGRepresentation(self);
    
    NSString *filePath = [NSString createUuid];
    filePath = [NSString cachesPathByAppendingPathComponent:filePath];
    
    [data writeToFile:filePath atomically:NO];
    
    return filePath;
}

@end
