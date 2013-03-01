#import <Foundation/Foundation.h>

@interface NSString (Format)

+ (id)stringWithFormatCheckNill:(NSString *)format, ...;

- (NSString *)singleQuotedString;

@end
