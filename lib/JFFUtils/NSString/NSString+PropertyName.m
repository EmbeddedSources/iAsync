#import "NSString+PropertyName.h"

static NSString* setterPreffix = @"set";
static NSString* setterSuffix  = @":";

@implementation NSString (PropertyName)

-(id)propertyGetNameFromPropertyName
{
    NSUInteger stringLength_ = [self length];
    if ( stringLength_ <= 4
        || [self characterAtIndex:stringLength_ - 1] != ':'
        || ![self hasPrefix:setterPreffix] )
        return nil;

    NSRange range1_ = { 3, 1 };
    NSString* namePart1_ = [ self substringWithRange: range1_ ];
    NSRange range2_ = { 4, stringLength_ - 5 };
    NSString* namePart2_ = [ self substringWithRange: range2_ ];

    return [ [ namePart1_ lowercaseString ] stringByAppendingString: namePart2_ ];
}

-(id)propertySetNameForPropertyName
{
    if ([self hasSuffix: setterSuffix])
        return nil;

    NSUInteger stringLength = [self length];
    NSRange range1 = {0, 1};
    NSString *propertyNamePart1 = [[self substringWithRange:range1]capitalizedString];
    NSRange range2 = {1, stringLength - 1};
    NSString *propertyNamePart2= [self substringWithRange:range2];
    NSString *result = [propertyNamePart1 stringByAppendingString:propertyNamePart2];

    return [[setterPreffix stringByAppendingString:result]stringByAppendingString:setterSuffix];
}

@end
