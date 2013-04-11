#import "NSSet+BlocksAdditions.h"

#import "NSArray+BlocksAdditions.h"

@implementation NSMutableSet (BlocksAdditions)

+ (id)converToCurrentTypeMutableSet:(NSMutableSet *)set
{
    return set;
}

@end

@implementation NSSet (BlocksAdditions)

+ (id)converToCurrentTypeMutableSet:(NSMutableSet *)set
{
    return [set copy];
}

+ (id)setWithSize:(NSUInteger)size
         producer:(JFFProducerBlock)block
{
    NSMutableSet *result = [[NSMutableSet alloc] initWithCapacity:size];
    
    for (NSUInteger index = 0; index < size; ++index) {
        [result addObject:block(index)];
    }
    
    return [self converToCurrentTypeMutableSet:result];
}

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
