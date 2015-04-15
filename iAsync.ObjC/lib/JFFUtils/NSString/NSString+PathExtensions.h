#import <Foundation/Foundation.h>

@interface NSString (PathExtensions)

+ (instancetype)documentsPathByAppendingPathComponent:(NSString *)str;

+ (instancetype)cachesPathByAppendingPathComponent:(NSString *)str;

@end
