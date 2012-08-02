#import "NSArray+RemoveDuplicates.h"
#import "NSArray+BlocksAdditions.h"
#import "NSArray+IsEmpty.h"

#import "JFFClangLiterals.h"

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
    NSUInteger itemsCount_ = [ self count ];

    NSMutableSet*   processedObjects_ = [ [ NSMutableSet alloc ] initWithCapacity  : itemsCount_ ];
    NSMutableArray* result_           = [ [ NSMutableArray alloc ] initWithCapacity: itemsCount_ ];

    for ( id item_ in self )
    {
        if ( ![ processedObjects_ containsObject: item_ ] )
        {
            [ result_           addObject: item_ ];
            [ processedObjects_ addObject: item_ ];
        }
    }

    //Shrink the capacity
    return [ result_ copy ];
}

-(NSArray*)uniqueBy:( JFFEqualityCheckerBlock )predicate_
{
    NSMutableArray* myCopy_ = [ self mutableCopy ];

    NSUInteger itemsCount_ = [ self count ];
    NSMutableArray* result_ = [ [ NSMutableArray alloc ] initWithCapacity: itemsCount_ ];

    NSArray* filtered_ = nil;
    JFFPredicateBlock searchPredicate_ = nil;
    while ( [ myCopy_ hasElements ] )
    {
        id firstItem_ = myCopy_[ 0 ];

        searchPredicate_ = ^BOOL( id itemObject_ )
        {
            return predicate_( firstItem_, itemObject_ );
        };
        filtered_ = [ myCopy_ select: searchPredicate_ ];

        [ result_ addObject: firstItem_ ];
        [ myCopy_ removeObjectsInArray: filtered_ ];
    }

    //Shrink the capacity
    return [ result_ copy ];
}

@end
