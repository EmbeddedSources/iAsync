#import <Foundation/Foundation.h>

@interface NSString (Format) 

+ (instancetype)stringWithFormatCheckNill:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

- (NSString *)singleQuotedString;

@end
