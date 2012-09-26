#import "NSString+PathExtensions.h"

@implementation NSString (PathExtensions)

+ (NSString *)pathWithDirectory:(NSSearchPathDirectory)directory
         appendingPathComponent:(NSString *)str
{
    NSArray  *pathes = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *documentDirectory = [pathes lastObject];
    return [documentDirectory stringByAppendingPathComponent:str];
}

+ (NSString *)documentsPathByAppendingPathComponent:(NSString *)str
{
    return [self pathWithDirectory:NSDocumentDirectory
            appendingPathComponent:str];
}

+ (NSString *)cachesPathByAppendingPathComponent:(NSString *)str
{
    return [self pathWithDirectory:NSCachesDirectory
            appendingPathComponent:str];
}

@end
