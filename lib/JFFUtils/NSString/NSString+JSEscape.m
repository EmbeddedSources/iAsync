#import "NSString+JSEscape.h"

@implementation NSString (JSEscape)

-(NSString *)stringByReplacingJSEscapes
{
    NSString *result = [ self stringByReplacingOccurrencesOfString:@"'" withString:@"\\'" ];

    return result;
}

@end
