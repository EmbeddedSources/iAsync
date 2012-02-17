#import "NSDictionary+XQueryComponents.h"

#import "NSString+XQueryComponents.h"
#import "NSArray+BlocksAdditions.h"
#import "NSArray+NoThrowObjectAtIndex.h"

static NSString* const query_component_format_ = @"%@=%@";
static NSString* const query_component_separator_ = @"&";

@interface NSObject (XQueryComponents)

-(NSArray*)arrayOfQueryComponentsForKey:( NSString* )key_;

@end

@implementation NSObject (XQueryComponents)

-(NSString*)stringFromQueryComponentAndKey:( NSString* )key_
{
   NSString* value_ = [ [ self description ] stringByEncodingURLFormat ];
   return [ NSString stringWithFormat: query_component_format_, key_, value_ ];
}

-(NSArray*)arrayOfQueryComponentsForKey:( NSString* )key_
{
   NSString* component_ = [ self stringFromQueryComponentAndKey: key_ ];
   return [ NSArray arrayWithObject: component_ ];
}

@end

@implementation NSArray (XQueryComponents)

-(NSArray*)arrayOfQueryComponentsForKey:( NSString* )key_
{
   return [ self map: ^id( id value_ )
   {
      return [ value_ stringFromQueryComponentAndKey: key_ ];;
   } ];
}

@end

@implementation NSDictionary (XQueryComponents)

-(NSString*)stringFromQueryComponents
{
   NSArray* result_ = [ [ self allKeys ] flatten: ^NSArray*( id key_ )
   {
      key_ = [ key_ stringByEncodingURLFormat ];
      NSObject* values_ = [ self objectForKey: key_ ];
      return [ values_ arrayOfQueryComponentsForKey: key_ ];
   } ];
   return [ result_ componentsJoinedByString: query_component_separator_ ];
}

-(NSString*)firstValueIfExsistsForKey:( NSString* )key_
{
   return [ [ self objectForKey: key_ ] noThrowObjectAtIndex: 0 ];
}

@end
