#import "NSArray+RemoveDuplicates.h"
#import "NSArray+BlocksAdditions.h"
#import "NSArray+IsEmpty.h"

@implementation NSArray( RemoveDuplicates )

-(NSArray*)arrayByRemovingDuplicates
{
    return [ self unique ];
}

-(NSArray*)arrayByRemovingDuplicatesUsingIsEqualBlock:( JFFEqualityCheckerBlock )predicate_
{
    return [ self uniqueBy: predicate_ ];
}

-(NSArray*)unique
{
    NSUInteger items_count_ = [ self count ];

    NSMutableSet*   processed_objects_ = [ NSMutableSet   setWithCapacity  : items_count_ ];
    NSMutableArray* result_            = [ NSMutableArray arrayWithCapacity: items_count_ ];

    for ( id item_ in self )
    {
        if ( ![ processed_objects_ containsObject: item_ ] )
        {
            [ result_            addObject: item_ ];
            [ processed_objects_ addObject: item_ ];
        }
    }

    //Shrink the capacity
    return [ NSArray arrayWithArray: result_ ];
}

-(NSArray*)uniqueBy:( JFFEqualityCheckerBlock )predicate_
{
    NSMutableArray* myCopy_ = [ [ NSMutableArray alloc ] initWithArray: self ];

    NSUInteger items_count_ = [ self count ];
    NSMutableArray* result_ = [ NSMutableArray arrayWithCapacity: items_count_ ];

    NSArray* filtered_ = nil;
    JFFPredicateBlock search_predicate_ = nil;
    while ( [ myCopy_ hasElements ] )
    {
        id firstItem_ = [ myCopy_ objectAtIndex: 0 ];

        search_predicate_ = ^BOOL( id itemObject_ )
        {
            return predicate_( firstItem_, itemObject_ );
        };
        filtered_ = [ myCopy_ select: search_predicate_ ];

        [ result_ addObject: firstItem_ ];
        [ myCopy_ removeObjectsInArray: filtered_ ];
    }

    //Shrink the capacity
    return [ NSArray arrayWithArray: result_ ];
}

@end
