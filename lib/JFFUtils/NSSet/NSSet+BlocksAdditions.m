#import "NSSet+BlocksAdditions.h"

#import "NSArray+BlocksAdditions.h"

@implementation NSMutableSet (BlocksAdditions)

+ (instancetype)converToCurrentTypeMutableSet:(NSMutableSet *)set
{
    return set;
}

@end

@implementation NSSet (BlocksAdditions)

+ (instancetype)converToCurrentTypeMutableSet:(NSMutableSet *)set
{
    return [set copy];
}

+ (instancetype)setWithSize:(NSUInteger)size
                   producer:(JFFProducerBlock)block
{
    NSMutableSet *result = [[NSMutableSet alloc] initWithCapacity:size];
    
    for (NSUInteger index = 0; index < size; ++index) {
        [result addObject:block(index)];
    }
    
    return [self converToCurrentTypeMutableSet:result];
}

- (instancetype)map:(JFFMappingBlock)block
{
    NSArray *arrray = [[self allObjects] map:block];
    return [NSSet setWithArray:arrray];
}

- (instancetype)forceMap:(JFFMappingBlock)block
{
    NSArray *arrray = [[self allObjects] forceMap:block];
    return [NSSet setWithArray:arrray];
}

- (instancetype)filter:(JFFPredicateBlock)predicate
{
    return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return predicate(obj);
    }];
}

- (NSArray *)filterArray:(JFFPredicateBlock)predicate
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
