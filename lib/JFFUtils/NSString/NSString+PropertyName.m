#import "NSString+PropertyName.h"

@implementation NSString (PropertyName)

+(id)propertyGetNameFromPropertyName:( NSString* )property_name_
{
   NSUInteger string_length_ = [ property_name_ length ];
   if ( string_length_ <= 4
       || [ property_name_ characterAtIndex: string_length_ - 1 ] != ':'
       || ![ property_name_ hasPrefix: @"set" ] )
      return nil;

   NSString* name_part1_ = [ property_name_ substringWithRange: NSMakeRange( 3, 1 ) ];
   NSString* name_part2_ = [ property_name_ substringWithRange: NSMakeRange( 4, string_length_ - 5 ) ];

   return [ [ name_part1_ lowercaseString ] stringByAppendingString: name_part2_ ];
}

+(id)propertySetNameFromPropertyName:( NSString* )property_name_
{
   NSUInteger string_length_ = [ property_name_ length ];
   NSString* property_name_part1_ = [ [ property_name_ substringWithRange: NSMakeRange( 0, 1 ) ] capitalizedString ];
   NSString* property_name_part2_ = [ property_name_ substringWithRange: NSMakeRange( 1, string_length_ - 1 ) ];
   property_name_ = [ property_name_part1_ stringByAppendingString: property_name_part2_ ];

   return [ [ @"set" stringByAppendingString: property_name_ ] stringByAppendingString: @":" ];
}

@end
