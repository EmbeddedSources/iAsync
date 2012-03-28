#import "NSDictionary+JFFExtendedDictionary.h"

@implementation NSDictionary (JFFExtendedDictionary)

-(NSDictionary*)dictionaryByAddingObjectsFromDictionary:( NSDictionary* )dictionary_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithDictionary: self ];

    for ( id key_ in dictionary_ )
    {
        id object_ = [ dictionary_ objectForKey: key_ ];
        [ result_ setObject: object_ forKey: key_ ];
    }

    return [ [ NSDictionary alloc ] initWithDictionary: result_ ];
}

@end
