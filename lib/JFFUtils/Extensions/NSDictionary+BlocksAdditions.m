#import "NSDictionary+BlocksAdditions.h"

@implementation NSDictionary (BlocksAdditions)

-(NSDictionary*)map:( JFFDictMappingBlock )block_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithCapacity: [ self count ] ];
    for ( id key_ in self )
    {
        id object_ = block_( key_, [ self objectForKey: key_ ] );
        if ( object_ )
            [ result_ setObject: object_ forKey: key_ ];
    }
    return [ [ NSDictionary alloc ] initWithDictionary: result_ ];
}

-(NSDictionary*)mapKey:( JFFDictMappingBlock )block_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithCapacity: [ self count ] ];
    for ( id key_ in self )
    {
        id object_ = [ self objectForKey: key_ ];
        id newKey_ = block_( key_, object_ );
        if ( newKey_ )
            [ result_ setObject: object_ forKey: newKey_ ];
    }
    return [ [ NSDictionary alloc ] initWithDictionary: result_ ];
}

-(NSUInteger)count:( JFFDictPredicateBlock )predicate_
{
    NSUInteger count_ = 0;
    for ( id key_ in self )
    {
        id object_ = [ self objectForKey: key_ ];
        if ( predicate_( key_, object_ ) )
            ++count_;
    }
    return count_;
}

@end
