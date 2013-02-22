#import "JFFMutableAssignDictionary.h"

#import "JFFAssignProxy.h"

#import "NSObject+OnDeallocBlock.h"
#import "NSArray+BlocksAdditions.h"
#import "NSDictionary+BlocksAdditions.h"

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
    self.onDeallocBlock = ^void(void) {
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
    [_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                  JFFAutoRemoveFromDictAssignProxy *proxy,
                                                                  BOOL *stop) {
        [proxy onRemoveFromMutableAssignDictionary:self];
    }];
    [_mutableDictionary removeAllObjects];
}

- (NSMutableDictionary *)mutableDictionary
{
    if (!_mutableDictionary) {
        _mutableDictionary = [NSMutableDictionary new];
    }
    return _mutableDictionary;
}

- (NSUInteger)count
{
    return [_mutableDictionary count];
}

- (id)objectForKey:(id)key
{
    JFFAutoRemoveFromDictAssignProxy *proxy = _mutableDictionary[key];
    return proxy.target;
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(id key,
                                                                  JFFAutoRemoveFromDictAssignProxy *proxy,
                                                                  BOOL *stop) {
        block(key, proxy.target, stop);
    }];
}

- (NSDictionary*)map:(JFFDictMappingBlock)block
{
    return [_mutableDictionary map:^id(id key, JFFAutoRemoveFromDictAssignProxy *proxy) {
        return block(key, proxy.target);
    }];
}

- (void)removeObjectForKey:(id)key
{
    JFFAutoRemoveFromDictAssignProxy *proxy = _mutableDictionary[key];
    [proxy onRemoveFromMutableAssignDictionary:self];
    [_mutableDictionary removeObjectForKey:key];
}

- (void)setObject:(id)object forKey:(id)key
{
    id previousObject = self[key];
    if (previousObject)
        [self removeObjectForKey:key];
    
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
    return [_mutableDictionary description];
}

@end
