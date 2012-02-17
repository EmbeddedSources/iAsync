#import "NSArray+RemoveDuplicates.h"
#import "NSArray+BlocksAdditions.h"
#import "NSArray+IsEmpty.h"

@implementation NSArray( RemoveDuplicates )

-(NSArray*)arrayByRemovingDuplicates
{
   return [ self unique ];
}

-(NSArray*)arrayByRemovingDuplicatesUsingIsEqualBlock:( EqualityCheckerBlock )predicate_
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

-(NSArray*)uniqueBy:( EqualityCheckerBlock )predicate_
{
   NSMutableArray* my_copy_ = [ NSMutableArray arrayWithArray: self ];

   NSUInteger items_count_ = [ self count ];
   NSMutableArray* result_ = [ NSMutableArray arrayWithCapacity: items_count_ ];

   NSArray* filtered_ = nil;
   PredicateBlock search_predicate_ = nil;
   while ( [ my_copy_ hasElements ] )
   {
      id first_item_ = [ my_copy_ objectAtIndex: 0 ];

      search_predicate_ = ^( id item_object_ )
      {
         return predicate_( first_item_, item_object_ );
      };
      filtered_ = [ my_copy_ select: search_predicate_ ];

      [ result_ addObject: first_item_ ];
      [ my_copy_ removeObjectsInArray: filtered_ ];
   }

   //Shrink the capacity
   return [ NSArray arrayWithArray: result_ ];
}

@end
