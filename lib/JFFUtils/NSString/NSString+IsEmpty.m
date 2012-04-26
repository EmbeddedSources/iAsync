#import "NSString+IsEmpty.h"

@implementation NSString (IsEmpty)

-(BOOL)hasSymbols
{
    return ![ self isEqualToString: @"" ];
}

@end
