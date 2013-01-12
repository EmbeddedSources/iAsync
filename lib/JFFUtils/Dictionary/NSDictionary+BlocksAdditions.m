#import "NSDictionary+BlocksAdditions.h"

#import "JFFClangLiterals.h"

@implementation NSDictionary (BlocksAdditions)

- (NSDictionary *)map:(JFFDictMappingBlock)block
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        id newObject = block(key, object);
        NSParameterAssert(newObject);
        result[key] = newObject;
    }];
    return [result copy];
}

- (NSDictionary *)map:(JFFDictMappingWithErrorBlock)block error:(NSError *__autoreleasing *)outError
{
    __block NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    __block NSError *error;
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        id newObject = block(key, object, &error);
        
        if (!newObject) {
            *stop = YES;
            result = nil;
            return;
        }
        
        result[key] = newObject;
    }];
    
    if (outError)
        *outError = error;
    
    return [result copy];
}

-(NSDictionary*)mapKey:(JFFDictMappingBlock)block
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        id newKey = block(key, object);
        NSParameterAssert(newKey);
        result[newKey] = object;
    }];
    return [result copy];
}

- (NSUInteger)count:(JFFDictPredicateBlock)predicate
{
    __block NSUInteger count = 0;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        if (predicate(key, object))
            ++count;
    }];
    return count;
}

- (void)each:(JFFDictActionBlock)block
{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        block(key, object);
    }];
}

- (NSDictionary*)select:(JFFDictPredicateBlock)predicate
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if (predicate(key, obj)) {
            
            result[key] = obj;
        }
    }];
    
    return [result copy];
}

@end
