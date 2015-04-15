#import "NSString+PathExtensions.h"

@implementation NSString (PathExtensions)

+ (instancetype)pathForDirectory:(NSSearchPathDirectory)directory
{
    NSArray  *pathes = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    return [pathes lastObject];
}

+ (instancetype)documentsPathByAppendingPathComponent:(NSString *)str
{
    static NSString *documentsDirectory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        documentsDirectory = [self pathForDirectory:NSDocumentDirectory];
    });
    
    return [ documentsDirectory stringByAppendingPathComponent: str ];
}

+ (instancetype)cachesPathByAppendingPathComponent:(NSString *)str
{
    static NSString *cachesDirectory = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
       cachesDirectory = [self pathForDirectory:NSCachesDirectory];
    });
    
    return [cachesDirectory stringByAppendingPathComponent:str];
}

@end
