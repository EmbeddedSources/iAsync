#import "NSString+StringWithCutPrefix.h"

@implementation NSString (StringWithCutPrefix)

- (instancetype)stringWithCutPrefix:(NSString *)prefix
{
    return [self hasPrefix:prefix]
    ?[self substringFromIndex:[prefix length]]
    :self;
}

@end
