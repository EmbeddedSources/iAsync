#import "NSSet+BlocksAdditions.h"

@implementation NSSet (BlocksAdditions)

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
