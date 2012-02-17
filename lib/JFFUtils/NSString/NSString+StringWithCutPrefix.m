#import "NSString+StringWithCutPrefix.h"

@implementation NSString (StringWithCutPrefix)

-(id)stringWithCutPrefix:( NSString* )prefix_
{
    return [ self hasPrefix: prefix_ ]
        ? [ self substringFromIndex: [ prefix_ length ] ]
        : self;
}

@end
