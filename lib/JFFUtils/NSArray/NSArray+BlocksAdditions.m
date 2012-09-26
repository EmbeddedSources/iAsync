#import "NSArray+BlocksAdditions.h"

#import "JFFClangLiterals.h"

@implementation NSMutableArray (BlocksAdditions)

+ (id)converToCurrentTypeMutableArray:(NSMutableArray *)array
{
    return array;
}

@end

@implementation NSArray (BlocksAdditions)

+ (id)converToCurrentTypeMutableArray:(NSMutableArray *)array
{
    return [array copy];
}

+ (id)arrayWithSize:(NSUInteger)size
           producer:(JFFProducerBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:size];

    for ( NSUInteger index = 0; index < size; ++index )
    {
        [result addObject:block(index)];
    }

    return [self converToCurrentTypeMutableArray:result];
}

+ (id)arrayWithCapacity:(NSUInteger)capacity
   ignoringNilsProducer:(JFFProducerBlock)block
{
    NSMutableArray* result = [[NSMutableArray alloc]initWithCapacity:capacity];

    for ( NSUInteger index = 0; index < capacity; ++index )
    {
        id object = block(index);
        if (object)
            [result addObject:object];
    }

    return [self converToCurrentTypeMutableArray:result];
}

- (void)each:(JFFActionBlock)block
{
    [self enumerateObjectsUsingBlock:^void(id obj, NSUInteger idx, BOOL *stop)
    {
        block(obj);
    }];
}

- (NSArray*)select:(JFFPredicateBlock)predicate
{
    return [self selectWithIndex:^(id obj, NSUInteger idx)
    {
        return predicate(obj);
    }];
}

- (NSArray*)selectWithIndex:(JFFPredicateWithIndexBlock)predicate
{
    NSIndexSet *indexes = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) 
    {
        return predicate(obj, idx);
    }];
    return [self objectsAtIndexes:indexes];
}

- (NSArray*)map:(JFFMappingBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[self count]];
    
    for (id object in self)
    {
        [result addObject:block(object)];
    }
    
    return [result copy];
}

- (NSArray*)map:(JFFMappingWithErrorBlock)block error:(NSError **)outError
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[self count]];

    for (id object in self)
    {
        id newObject = block(object, outError);
        if (newObject)
        {
            [result addObject:newObject];
        }
        else
        {
            return nil;
        }
    }

    return [result copy];
}

- (NSArray*)forceMap:(JFFMappingBlock)block
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[self count]];

    for (id object in self)
    {
        id newObject = block(object);
        if (newObject)
        {
            [result addObject:newObject];
        }
    }

    return [result copy];
}

- (NSArray *)mapWithIndex:(JFFMappingWithErrorAndIndexBlock)block error:(NSError **)outError
{
    __block NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity: [self count]];
    
    [self enumerateObjectsUsingBlock: ^(id object, NSUInteger idx, BOOL *stop)
    {
        id newObject = block(object, idx, outError);
        if (newObject)
        {
            [result addObject: newObject];
        }
        else
        {
            result = nil;
            *stop  = YES;
        }
    } ];
    
    return [result copy];
}

- (NSDictionary *)mapDict:(JFFMappingDictBlock)block
{
    NSMutableArray *keys   = [[NSMutableArray alloc] initWithCapacity:[self count]];
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[self count]];

    for ( id object in self )
    {
        id key;
        id value;
        block(object, &key, &value);
        [keys   addObject: key  ];
        [values addObject: value];
    }
    
    return [[NSDictionary alloc] initWithObjects: values
                                         forKeys: keys];
}

- (NSArray *)flatten:(JFFFlattenBlock)block
{
    NSMutableArray *result = [NSMutableArray new];
    
    [self each:^void(id object)
    {
        NSArray *objectItems = block(object);
        [result addObjectsFromArray:objectItems];
    }];
    
    return [result copy];
}

- (NSUInteger)count:(JFFPredicateBlock)predicate
{
    __block NSUInteger count = 0;
    
    [self each: ^void(id object)
    {
        if (predicate(object))
            ++count;
    }];
    
    return count;
}

- (id)firstMatch:(JFFPredicateBlock)predicate
{
    for (id object in self)
    {
        if (predicate(object))
            return object;
    }
    return nil;
}

- (NSUInteger)firstIndexOfObjectMatch:(JFFPredicateBlock)predicate
{
    NSUInteger result = 0;
    for (id object in self)
    {
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
    
    NSUInteger arraySize = [self count];
    for (NSUInteger itemIndex = 0; itemIndex < arraySize; ++itemIndex)
    {
        block(self[itemIndex], other[itemIndex]);
    }
}

- (NSArray *)devideIntoArrayWithSize:(NSUInteger)size
                   elementIndexBlock:(JFFElementIndexBlock)block
{
    NSParameterAssert(size > 0);
    NSParameterAssert(block   );
    
    NSMutableArray *mResult = [NSMutableArray arrayWithSize: size
                                                   producer: ^id(NSUInteger index)
    {
        return [NSMutableArray new];
    }];
    
    [self enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
    {
        NSUInteger inserIndex = block(obj);
        [mResult[inserIndex] addObject: obj];
    }];
    
    NSArray *result = [mResult map: ^id(id object)
    {
        return [object copy];
    }];
    
    return result;
}

@end
