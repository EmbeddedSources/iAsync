#import "NSString+PropertyName.h"

@implementation NSString (PropertyName)

-(id)propertyGetNameFromPropertyName
{
    NSUInteger string_length_ = [ self length ];
    if ( string_length_ <= 4
        || [ self characterAtIndex: string_length_ - 1 ] != ':'
        || ![ self hasPrefix: @"set" ] )
        return nil;

    NSString* namePart1_ = [ self substringWithRange: NSMakeRange( 3, 1 ) ];
    NSString* namePart2_ = [ self substringWithRange: NSMakeRange( 4, string_length_ - 5 ) ];

    return [ [ namePart1_ lowercaseString ] stringByAppendingString: namePart2_ ];
}

-(id)propertySetNameForPropertyName
{
    if ( [ self hasSuffix: @":" ] )
        return nil;

    NSUInteger string_length_ = [ self length ];
    NSString* property_name_part1_ = [ [ self substringWithRange: NSMakeRange( 0, 1 ) ] capitalizedString ];
    NSString* property_name_part2_ = [ self substringWithRange: NSMakeRange( 1, string_length_ - 1 ) ];
    NSString* result_ = [ property_name_part1_ stringByAppendingString: property_name_part2_ ];

    return [ [ @"set" stringByAppendingString: result_ ] stringByAppendingString: @":" ];
}

@end
