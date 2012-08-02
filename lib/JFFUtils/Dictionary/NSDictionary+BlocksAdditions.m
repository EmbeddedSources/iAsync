#import "NSDictionary+BlocksAdditions.h"

#import "JFFClangLiterals.h"

@implementation NSDictionary (BlocksAdditions)

-(NSDictionary*)map:( JFFDictMappingBlock )block_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithCapacity: [ self count ] ];
    [ self enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL* stop_ )
    {
        id newObject_ = block_( key_, object_ );
        if ( newObject_ )
            result_[ key_ ] = newObject_;
    } ];
    return [ result_ copy ];
}

-(NSDictionary*)mapKey:( JFFDictMappingBlock )block_
{
    NSMutableDictionary* result_ = [ [ NSMutableDictionary alloc ] initWithCapacity: [ self count ] ];
    [ self enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL* stop_ )
    {
        id newKey_ = block_( key_, object_ );
        if ( newKey_ )
            result_[ newKey_ ] = object_;
    } ];
    return [ result_ copy ];
}

-(NSUInteger)count:( JFFDictPredicateBlock )predicate_
{
    __block NSUInteger count_ = 0;
    [ self enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL* stop_ )
    {
        if ( predicate_( key_, object_ ) )
            ++count_;
    } ];
    return count_;
}

-(void)each:( JFFDictActionBlock )block_
{
    [ self enumerateKeysAndObjectsUsingBlock: ^( id key_, id object_, BOOL* stop_ )
    {
        block_( key_, object_ );
    } ];
}

@end
