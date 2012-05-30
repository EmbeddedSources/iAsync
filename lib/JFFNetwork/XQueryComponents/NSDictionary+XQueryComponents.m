#import "NSDictionary+XQueryComponents.h"

#import "NSString+XQueryComponents.h"

static NSString* const queryComponentFormat_ = @"%@=%@";
static NSString* const queryComponentSeparator_ = @"&";

@interface NSObject (XQueryComponents)

-(NSArray*)arrayOfQueryComponentsForKey:( NSString* )key_;

@end

@implementation NSObject (XQueryComponents)

-(NSString*)stringFromQueryComponentAndKey:( NSString* )key_
{
    NSString* value_ = [ [ self description ] stringByEncodingURLFormat ];
    return [ [ NSString alloc ] initWithFormat: queryComponentFormat_, key_, value_ ];
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
        return [ value_ stringFromQueryComponentAndKey: key_ ];
    } ];
}

@end

@implementation NSDictionary (XQueryComponents)

-(NSString*)stringFromQueryComponents
{
    NSArray* result_ = [ [ self allKeys ] flatten: ^NSArray*( id key_ )
    {
        NSObject* values_ = [ self objectForKey: key_ ];
        NSString* encodedKey_ = [ key_ stringByEncodingURLFormat ];
        return [ values_ arrayOfQueryComponentsForKey: encodedKey_ ];
    } ];
    return [ result_ componentsJoinedByString: queryComponentSeparator_ ];
}

-(NSString*)firstValueIfExsistsForKey:( NSString* )key_
{
    return [ [ self objectForKey: key_ ] noThrowObjectAtIndex: 0 ];
}

@end
