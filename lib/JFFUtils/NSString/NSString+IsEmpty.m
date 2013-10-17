#import "NSString+IsEmpty.h"

@implementation NSString (IsEmpty)

- (BOOL)hasSymbols
{
    return ![self isEqualToString:@""];
}

- (BOOL)hasNonWhitespaceSymbols
{
    NSCharacterSet *whiteSpaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *stringWithoutWhiteSpaces = [self stringByTrimmingCharactersInSet:whiteSpaces];
    
    return [stringWithoutWhiteSpaces hasSymbols];
}

@end
