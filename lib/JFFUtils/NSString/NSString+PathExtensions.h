#import <Foundation/Foundation.h>

@interface NSString (PathExtensions)

+ (NSString *)documentsPathByAppendingPathComponent:(NSString *)str;

+ (NSString *)cachesPathByAppendingPathComponent:(NSString *)str;

@end
