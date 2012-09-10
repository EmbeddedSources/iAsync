#import "NSString+ToURL.h"

@implementation NSString (ToURL)

- (NSURL*)toURL
{
    return [[NSURL alloc]initWithString:self];
}

@end
