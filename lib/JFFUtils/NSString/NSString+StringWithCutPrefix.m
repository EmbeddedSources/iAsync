#import "NSString+StringWithCutPrefix.h"

@implementation NSString (StringWithCutPrefix)

- (id)stringWithCutPrefix:(NSString *)prefix
{
    return [self hasPrefix:prefix]
    ? [self substringFromIndex:[prefix length]]
    : self;
}

@end
