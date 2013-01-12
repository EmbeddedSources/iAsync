#import "NSOrderedSet+BlocksAdditions.h"

@implementation NSOrderedSet (BlocksAdditions)

//TODO test
//TODO remove code duplicate
- (NSOrderedSet *)map:(JFFMappingBlock)block
{
    NSMutableOrderedSet *result = [[NSMutableOrderedSet alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object);
        NSParameterAssert(newObject);
        [result addObject:newObject];
    }
    
    return [result copy];
}

- (NSOrderedSet *)forceMap:(JFFMappingBlock)block
{
    NSMutableOrderedSet *result = [[NSMutableOrderedSet alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object);
        if (newObject) {
            [result addObject:newObject];
        }
    }
    
    return [result copy];
}

- (id)firstMatch:(JFFPredicateBlock)predicate
{
    for (id object in self) {
        if (predicate(object))
            return object;
    }
    return nil;
}

- (BOOL)any:(JFFPredicateBlock)predicate
{
    id object = [self firstMatch:predicate];
    return object != nil;
}

- (BOOL)all:(JFFPredicateBlock)predicate
{
    JFFPredicateBlock notPredicate = ^BOOL(id object) {
        return !predicate(object);
    };
    return ![self any:notPredicate];
}

- (NSOrderedSet *)select:(JFFPredicateBlock)predicate
{
    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        
        return predicate(obj);
    }];
    return [[NSOrderedSet alloc] initWithArray:[self objectsAtIndexes:indexes]];
}

@end
