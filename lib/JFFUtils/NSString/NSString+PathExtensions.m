#import "NSString+PathExtensions.h"

@implementation NSString (PathExtensions)

+(NSString*)pathForDirectory:(NSSearchPathDirectory)directory
{
    NSArray  *pathes = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [pathes lastObject];
}

+ (NSString *)documentsPathByAppendingPathComponent:(NSString *)str
{
    static NSString *documentsDirectory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        documentsDirectory = [ self pathForDirectory: NSDocumentDirectory ];
    });
    
    return [ documentsDirectory stringByAppendingPathComponent: str ];
}

+ (NSString *)cachesPathByAppendingPathComponent:(NSString *)str
{
    static NSString *cachesDirectory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
       cachesDirectory = [ self pathForDirectory: NSCachesDirectory ];
    });
    
    return [ cachesDirectory stringByAppendingPathComponent: str ];
}

@end
