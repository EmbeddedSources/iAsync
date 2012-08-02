#import "NSSet+BlocksAdditions.h"

@implementation NSSet (BlocksAdditions)

-(NSSet*)select:( JFFPredicateBlock )predicate_
{
    NSMutableArray* result_ = [ NSMutableArray new ];
    for ( id object_ in self )
    {
        if ( predicate_( object_ ) )
            [ result_ addObject: object_ ];
    }
    return [ [ NSSet alloc ] initWithArray: result_ ];
}

-(NSArray*)selectArray:( JFFPredicateBlock )predicate_
{
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: [ self count ] ];
    for ( id object_ in self )
    {
        if ( predicate_( object_ ) )
            [ result_ addObject: object_ ];
    }
    return [ result_ copy ];
}

@end
