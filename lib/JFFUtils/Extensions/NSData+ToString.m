#import "NSData+ToString.h"

@implementation NSData (ToString)

- (NSString *)toString
{
    return [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
}

@end
