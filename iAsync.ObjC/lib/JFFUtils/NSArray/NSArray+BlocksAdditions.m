#import "NSArray+BlocksAdditions.h"

@implementation NSMutableArray (BlocksAdditions)

+ (instancetype)converToCurrentTypeMutableArray:(NSMutableArray *)array
{
    return array;
}

@end

@implementation NSArray (BlocksAdditions)

+ (instancetype)converToCurrentTypeMutableArray:(NSMutableArray *)array
{
    return [array copy];
}

+ (instancetype)arrayWithSize:(NSInteger)size
                     producer:(JFFProducerBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:size];
    
    for (NSInteger index = 0; index < size; ++index) {
        [result addObject:block(index)];
    }
    
    return [self converToCurrentTypeMutableArray:result];
}

+ (instancetype)arrayWithCapacity:(NSInteger)capacity
             ignoringNilsProducer:(JFFProducerBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:capacity];
    
    for (NSInteger index = 0; index < capacity; ++index) {
        id object = block(index);
        if (object)
            [result addObject:object];
    }
    
    return [self converToCurrentTypeMutableArray:result];
}

- (void)each:(JFFActionBlock)block
{
    [self enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (instancetype)filter:(JFFPredicateBlock)predicate
{
    return [self filterWithIndex:^(id obj, NSInteger idx) {
        return predicate(obj);
    }];
}

- (instancetype)filterWithIndex:(JFFPredicateWithIndexBlock)predicate
{
    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return predicate(obj, idx);
    }];
    return [self objectsAtIndexes:indexes];
}

- (instancetype)map:(JFFMappingBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object);
        NSParameterAssert(newObject);
        [result addObject:newObject];
    }
    
    return [result copy];
}

- (instancetype)map:(JFFMappingWithErrorBlock)block outError:(NSError **)outError
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object, outError);
        if (newObject) {
            [result addObject:newObject];
        } else {
            return nil;
        }
    }
    
    return [result copy];
}

- (instancetype)forceMap:(JFFMappingBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object);
        if (newObject) {
            [result addObject:newObject];
        }
    }
    
    return [result copy];
}

- (instancetype)mapWithIndex:(JFFMappingWithErrorAndIndexBlock)block outError:(NSError **)outError
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[self count]];
    
    __block NSError *error;
    
    [self enumerateObjectsUsingBlock: ^(id object, NSUInteger idx, BOOL *stop) {
        id newObject = block(object, idx, &error);
        if (newObject) {
            [result addObject: newObject];
        } else {
            result = nil;
            *stop  = YES;
        }
    }];
    
    if (outError)
        *outError = error;
    
    return [result copy];
}

- (NSDictionary *)mapDict:(JFFMappingDictBlock)block
{
    NSMutableArray *keys   = [[NSMutableArray alloc] initWithCapacity:[self count]];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[self count]];

    for ( id object in self ) {
        id key;
        id value;
        block(object, &key, &value);
        [keys   addObject:key  ];
        [values addObject:value];
    }
    
    return [[NSDictionary alloc] initWithObjects:values
                                         forKeys:keys];
}

- (instancetype)flatten:(JFFFlattenBlock)block
{
    NSMutableArray *result = [NSMutableArray new];
    
    [self each:^void(id object) {
        NSArray *objectItems = block(object);
        [result addObjectsFromArray:objectItems];
    }];
    
    return [result copy];
}

- (NSInteger)count:(JFFPredicateBlock)predicate
{
    __block NSInteger count = 0;
    
    [self each: ^void(id object) {
        if (predicate(object))
            ++count;
    }];
    
    return count;
}

- (id)firstMatch:(JFFPredicateBlock)predicate
{
    for (id object in self) {
        if (predicate(object))
            return object;
    }
    return nil;
}

- (id)lastMatch:(JFFPredicateBlock)predicate
{
    NSEnumerator *enumerator = [self reverseObjectEnumerator];
    for (id object in enumerator) {
        
        if (predicate(object))
            return object;
    }
    return nil;
}

- (NSInteger)firstIndexOfObjectMatch:(JFFPredicateBlock)predicate
{
    NSInteger result = 0;
    for (id object in self) {
        if (predicate(object))
            return result;
        ++result;
    }
    return NSNotFound;
}

- (void)transformWithArray:(NSArray *)other
                 withBlock:(JFFTransformBlock)block
{
    NSAssert([self count] == [other count], @"Dimensions must match to perform transform action");
    
    NSInteger arraySize = [self count];
    for (NSInteger itemIndex = 0; itemIndex < arraySize; ++itemIndex) {
        block(self[itemIndex], other[itemIndex]);
    }
}

- (instancetype)devideIntoArrayWithSize:(NSInteger)size
                      elementIndexBlock:(JFFElementIndexBlock)block
{
    NSParameterAssert(size > 0);
    NSParameterAssert(block   );
    
    NSMutableArray *mResult = [NSMutableArray arrayWithSize:size
                                                   producer:^id(NSInteger index) {
        return [NSMutableArray new];
    }];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger inserIndex = block(obj);
        [mResult[inserIndex] addObject: obj];
    }];
    
    NSArray *result = [mResult map:^id(id object) {
        return [object copy];
    }];
    
    return result;
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

@end
