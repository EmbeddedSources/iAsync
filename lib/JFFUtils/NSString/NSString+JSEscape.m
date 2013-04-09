#import "NSString+JSEscape.h"

@implementation NSString (JSEscape)

-(NSString *)stringByReplacingJSEscapes:(NSString *)sourceString
{
    NSString *result = [ sourceString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'" ];

    return result;
}

@end
