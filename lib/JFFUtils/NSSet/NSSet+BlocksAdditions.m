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
    NSMutableArray *result = [NSMutableArray new];
    for (id object in self) {
        if (predicate(object))
            [result addObject:object];
    }
    return [[NSSet alloc] initWithArray:result];
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

@end
