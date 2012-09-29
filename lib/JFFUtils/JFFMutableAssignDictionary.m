#import "JFFMutableAssignDictionary.h"

#import "JFFAssignProxy.h"

#import "NSObject+OnDeallocBlock.h"
#import "NSArray+BlocksAdditions.h"

#include "JFFUtilsBlockDefinitions.h"

#import "JFFClangLiterals.h"

@interface JFFAutoRemoveFromDictAssignProxy : JFFAssignProxy

@property (nonatomic, copy) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveFromDictAssignProxy

- (void)onAddToMutableAssignDictionary:(JFFMutableAssignDictionary *)dict
                                   key:(id)key
{
    __unsafe_unretained JFFMutableAssignDictionary *unretainedDict = dict;
    self.onDeallocBlock = ^void(void)
    {
        [unretainedDict removeObjectForKey:key];
    };
    [self.target addOnDeallocBlock:self.onDeallocBlock];
}

- (void)onRemoveFromMutableAssignDictionary:(JFFMutableAssignDictionary *)array
{
    [self.target removeOnDeallocBlock:self.onDeallocBlock];
    self.onDeallocBlock = nil;
}

@end

@interface JFFMutableAssignDictionary ()

@property (nonatomic) NSMutableDictionary *mutableDictionary;

@end

@implementation JFFMutableAssignDictionary

- (void)dealloc
{
    [self removeAllObjects];
}

- (void)removeAllObjects
{
    [self->_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                  JFFAutoRemoveFromDictAssignProxy *proxy,
                                                                  BOOL *stop)
    {
        [proxy onRemoveFromMutableAssignDictionary:self];
    } ];
    [self->_mutableDictionary removeAllObjects];
}

- (NSMutableDictionary *)mutableDictionary
{
    if (!self->_mutableDictionary)
    {
        self->_mutableDictionary = [NSMutableDictionary new];
    }
    return self->_mutableDictionary;
}

- (NSUInteger)count
{
    return [self->_mutableDictionary count];
}

- (id)objectForKey:(id)key
{
    JFFAutoRemoveFromDictAssignProxy *proxy = self->_mutableDictionary[key];
    return proxy.target;
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self->_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                  JFFAutoRemoveFromDictAssignProxy *proxy,
                                                                  BOOL *stop)
    {
        block(key, proxy.target, stop);
    }];
}

//TODO test
- (NSDictionary*)map:(JFFDictMappingBlock)block
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        id newObject = block(key, object);
        NSParameterAssert(newObject);
        result[key] = newObject;
    }];
    return [result copy];
}

- (void)removeObjectForKey:(id)key
{
    JFFAutoRemoveFromDictAssignProxy *proxy = self->_mutableDictionary[key];
    [proxy onRemoveFromMutableAssignDictionary:self];
    [self->_mutableDictionary removeObjectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key
{
    id previousObject = self[key];
    if (previousObject) {
        [self removeObjectForKey:key];
    }
    
    JFFAutoRemoveFromDictAssignProxy *proxy = [[JFFAutoRemoveFromDictAssignProxy alloc] initWithTarget:object];
    self.mutableDictionary[key] = proxy;
    [proxy onAddToMutableAssignDictionary:self key:key];
}

- (void)setObject:(id)newValue forKeyedSubscript:(id)key
{
    [self setObject:newValue forKey:key];
}

- (NSString *)description
{
    return [self->_mutableDictionary description];
}

@end
