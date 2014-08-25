#import "NSArray+RemoveDuplicates.h"
#import "NSArray+BlocksAdditions.h"
#import "NSArray+IsEmpty.h"

@implementation NSArray( RemoveDuplicates )

- (instancetype)arrayByRemovingDuplicates
{
    return [self unique];
}

- (instancetype)arrayByRemovingDuplicatesUsingIsEqualBlock:(JFFEqualityCheckerBlock)predicate
{
    return [self uniqueBy:predicate];
}

- (instancetype)unique
{
    NSUInteger itemsCount = [self count];
    
    NSMutableSet   *processedObjects = [[NSMutableSet   alloc] initWithCapacity:itemsCount];
    NSMutableArray *result           = [[NSMutableArray alloc] initWithCapacity:itemsCount];
    
    for (id item in self) {
        if (![processedObjects containsObject:item]) {
            [result           addObject:item];
            [processedObjects addObject:item];
        }
    }
    
    //Shrink the capacity
    return [result copy];
}

- (instancetype)uniqueBy:(JFFEqualityCheckerBlock)predicate
{
    NSMutableArray *myCopy = [self mutableCopy];
    
    NSUInteger itemsCount  = [self count];
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:itemsCount];
    
    NSArray *filtered = nil;
    JFFPredicateBlock searchPredicate = nil;
    while ([myCopy hasElements]) {
        id firstItem = myCopy[0];
        
        searchPredicate = ^BOOL(id itemObject) {
            return predicate(firstItem, itemObject);
        };
        filtered = [myCopy filter:searchPredicate];
        
        [result addObject:firstItem];
        [myCopy removeObjectsInArray:filtered];
    }
    
    //Shrink the capacity
    return [result copy];
}

@end
