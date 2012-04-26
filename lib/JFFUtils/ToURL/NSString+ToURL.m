#import "NSString+ToURL.h"

@implementation NSString (ToURL)

-(NSURL*)toURL
{
    return [ NSURL URLWithString: self ];
}

@end
