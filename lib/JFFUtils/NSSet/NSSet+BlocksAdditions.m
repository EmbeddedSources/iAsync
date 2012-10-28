#import "NSSet+BlocksAdditions.h"

#import "NSArray+BlocksAdditions.h"

@implementation NSSet (BlocksAdditions)

- (NSSet *)map:(JFFMappingBlock)block
{
    NSArray *arrray = [[self allObjects] map:block];
    return [NSSet setWithArray:arrray];
}

- (NSSet *)forceMap:(JFFMappingBlock)block
{
    NSArray *arrray = [[self allObjects] forceMap:block];
    return [NSSet setWithArray:arrray];
}

- (NSSet *)select:(JFFPredicateBlock)predicate
{
    return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return predicate(obj);
    }];
}

- (NSArray *)selectArray:(JFFPredicateBlock)predicate
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    for (id object in self) {
        if (predicate(object))
            [result addObject:object];
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

@end
