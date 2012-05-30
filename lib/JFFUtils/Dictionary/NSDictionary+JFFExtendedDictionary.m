#import "NSDictionary+JFFExtendedDictionary.h"

@implementation NSDictionary (JFFExtendedDictionary)

-(NSDictionary*)dictionaryByAddingObjectsFromDictionary:( NSDictionary* )dictionary_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithDictionary: self ];

    [ dictionary_ enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL *stop_ )
    {
        [ result_ setObject: object_ forKey: key_ ];
    } ];

    return [ [ NSDictionary alloc ] initWithDictionary: result_ ];
}

@end
