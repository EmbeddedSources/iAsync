#import "NSString+JSEscape.h"

@implementation NSString (JSEscape)

- (instancetype)stringByReplacingJSEscapes
{
    NSString *result = [ self stringByReplacingOccurrencesOfString:@"'" withString:@"\\'" ];
    
    return result;
}

@end
