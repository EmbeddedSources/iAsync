#import <Foundation/Foundation.h>

@interface NSString (Format) 

+ (instancetype)stringWithFormatCheckNill:(NSString *)format, ...;

- (NSString *)singleQuotedString;

@end
