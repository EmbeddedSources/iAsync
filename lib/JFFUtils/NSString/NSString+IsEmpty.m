#import "NSString+IsEmpty.h"

@implementation NSString (IsEmpty)

-(BOOL)hasSymbols
{
    return ![ self isEqualToString: @"" ];
}

-(BOOL)hasNonWhitespaceSymbols
{
    NSCharacterSet *whiteSpaces_ = [ NSCharacterSet whitespaceAndNewlineCharacterSet ];
    NSString *stringWithoutWhiteSpaces_ = [ self stringByTrimmingCharactersInSet: whiteSpaces_ ];

    return [ stringWithoutWhiteSpaces_ hasSymbols];
}

@end
