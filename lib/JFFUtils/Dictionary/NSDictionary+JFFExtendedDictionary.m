#import "NSDictionary+JFFExtendedDictionary.h"

#import "JFFClangLiterals.h"

@implementation NSDictionary (JFFExtendedDictionary)

-(NSDictionary*)dictionaryByAddingObjectsFromDictionary:( NSDictionary* )dictionary_
{
    NSMutableDictionary* result_ = [ self mutableCopy ];

    [ dictionary_ enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL *stop_ )
    {
        result_[ key_ ] = object_;
    } ];

    return [ result_ copy ];
}

@end
