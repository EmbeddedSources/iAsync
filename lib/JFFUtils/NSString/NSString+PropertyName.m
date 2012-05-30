#import "NSString+PropertyName.h"

static NSString* setterPreffix_ = @"set";
static NSString* setterSuffix_ = @":";

@implementation NSString (PropertyName)

-(id)propertyGetNameFromPropertyName
{
    NSUInteger stringLength_ = [ self length ];
    if ( stringLength_ <= 4
        || [ self characterAtIndex: stringLength_ - 1 ] != ':'
        || ![ self hasPrefix: setterPreffix_ ] )
        return nil;

    NSRange range1_ = { 3, 1 };
    NSString* namePart1_ = [ self substringWithRange: range1_ ];
    NSRange range2_ = { 4, stringLength_ - 5 };
    NSString* namePart2_ = [ self substringWithRange: range2_ ];

    return [ [ namePart1_ lowercaseString ] stringByAppendingString: namePart2_ ];
}

-(id)propertySetNameForPropertyName
{
    if ( [ self hasSuffix: setterSuffix_ ] )
        return nil;

    NSUInteger stringLength_ = [ self length ];
    NSRange range1_ = { 0, 1 };
    NSString* propertyNamePart1_ = [ [ self substringWithRange: range1_ ] capitalizedString ];
    NSRange range2_ = { 1, stringLength_ - 1 };
    NSString* propertyNamePart2_ = [ self substringWithRange: range2_ ];
    NSString* result_ = [ propertyNamePart1_ stringByAppendingString: propertyNamePart2_ ];

    return [ [ setterPreffix_ stringByAppendingString: result_ ] stringByAppendingString: setterSuffix_ ];
}

@end
