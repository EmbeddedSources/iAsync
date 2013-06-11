#import "JFFMutableAssignKeyDictionary.h"

#import "NSObject+OnDeallocBlock.h"
#include "JFFRuntimeAddiotions.h"

#include <map>

@class JFFMutableAssignDictionaryKeyWrapper;

typedef std::map<__unsafe_unretained id, JFFSimpleBlock> BlockByPtr;

@interface JFFCPPMapONDeallocBlockByArrayPtrHolder : NSObject
{
@public
    BlockByPtr _map;
}

@end

@implementation JFFCPPMapONDeallocBlockByArrayPtrHolder
@end

@interface NSObject (JFFMutableAssignKeyDictionary)

@property (nonatomic) JFFCPPMapONDeallocBlockByArrayPtrHolder *mutableAssignKeyDictionaryOnDeallocBlock;

@end

@implementation NSObject (JFFMutableAssignKeyDictionary)

@dynamic mutableAssignKeyDictionaryOnDeallocBlock;

+ (void)load
{
    jClass_implementProperty(self, @"mutableAssignKeyDictionaryOnDeallocBlock");
}

- (JFFCPPMapONDeallocBlockByArrayPtrHolder *)lazyMutableAssignKeyDictionaryOnDeallocBlock
{
    JFFCPPMapONDeallocBlockByArrayPtrHolder *result = [self mutableAssignKeyDictionaryOnDeallocBlock];
    
    if (!result) {
        
        result = [JFFCPPMapONDeallocBlockByArrayPtrHolder new];
        self.mutableAssignKeyDictionaryOnDeallocBlock = result;
    }
    
    return result;
}

- (void)onAddToMutableAssignKeyDictionary:(JFFMutableAssignKeyDictionary *)dict
{
    __unsafe_unretained JFFMutableAssignKeyDictionary *unretainedDict = dict;
    __unsafe_unretained NSObject                      *unretainedSelf = self;
    
    [self onRemoveFromMutableAssignKeyDictionary:dict];
    
    JFFSimpleBlock onDeallocBlock = [^void(void) {
        
        [unretainedDict removeObjectForKey:unretainedSelf];
    } copy];
    
    self.lazyMutableAssignKeyDictionaryOnDeallocBlock->_map[dict] = onDeallocBlock;
    
    [self addOnDeallocBlock:onDeallocBlock];
}

- (void)onRemoveFromMutableAssignKeyDictionary:(JFFMutableAssignKeyDictionary *)dict
{
    JFFCPPMapONDeallocBlockByArrayPtrHolder *mutableAssignKeyDictionaryOnDeallocBlock = self.mutableAssignKeyDictionaryOnDeallocBlock;
    
    if (!mutableAssignKeyDictionaryOnDeallocBlock)
        return;
    
    BlockByPtr::iterator it = mutableAssignKeyDictionaryOnDeallocBlock->_map.find(dict);
    
    if (it != mutableAssignKeyDictionaryOnDeallocBlock->_map.end()) {
        
        JFFSimpleBlock onDeallocBlock = it->second;
        [self removeOnDeallocBlock:onDeallocBlock];
        
        mutableAssignKeyDictionaryOnDeallocBlock->_map.erase(it);
    }
}

@end

@interface JFFMutableAssignDictionaryKeyWrapper : NSObject <NSCopying>

@property (nonatomic, unsafe_unretained, readonly) NSObject *dictKeyObject;

@end

@implementation JFFMutableAssignDictionaryKeyWrapper

- (BOOL)isEqual:(JFFMutableAssignDictionaryKeyWrapper *)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return _dictKeyObject == object->_dictKeyObject;
}

- (NSUInteger)hash
{
    return (NSUInteger)((__bridge void*)_dictKeyObject);
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFMutableAssignDictionaryKeyWrapper *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_dictKeyObject = _dictKeyObject;
    }
    
    return copy;
}

- (instancetype)initWithDictKeyObject:(__unsafe_unretained id)object
{
    self = [super init];
    
    if (self) {
        
        _dictKeyObject = object;
    }
    
    return self;
}

@end

@implementation JFFMutableAssignKeyDictionary
{
    NSMutableDictionary *_mutableDictionary;
}

- (void)dealloc
{
    [self removeAllObjects];
}

- (NSMutableDictionary *)mutableDictionary
{
    if (!_mutableDictionary) {
        _mutableDictionary = [NSMutableDictionary new];
    }
    return _mutableDictionary;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(JFFMutableAssignDictionaryKeyWrapper *key, id obj, BOOL *stop) {
        
        block(key.dictKeyObject, obj, stop);
    }];
}

- (NSDictionary *)map:(JFFDictMappingBlock)block
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
    
    [_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(JFFMutableAssignDictionaryKeyWrapper *internalKey, id object, BOOL *stop) {
        
        id key = internalKey.dictKeyObject;
        id newObject = block(key, object);
        NSParameterAssert(newObject);
        result[key] = newObject;
    }];
    
    return [result copy];
}

- (NSUInteger)count
{
    return [_mutableDictionary count];
}

- (id)objectForKey:(id)key
{
    return [self objectForKeyedSubscript:key];
}

- (id)objectForKeyedSubscript:(id)key
{
    id internalKey = [[JFFMutableAssignDictionaryKeyWrapper alloc] initWithDictKeyObject:key];
    return _mutableDictionary[internalKey];
}

- (void)removeObjectForKey:(__unsafe_unretained id)key
{
    [key onRemoveFromMutableAssignKeyDictionary:self];
    
    id internalKey = [[JFFMutableAssignDictionaryKeyWrapper alloc] initWithDictKeyObject:key];
    [_mutableDictionary removeObjectForKey:internalKey];
}

- (void)setObject:(id)newValue forKey:(id)key
{
    [self setObject:newValue forKeyedSubscript:key];
}

- (void)setObject:(id)newValue forKeyedSubscript:(id)key
{
    [key onAddToMutableAssignKeyDictionary:self];
    
    id internalKey = [[JFFMutableAssignDictionaryKeyWrapper alloc] initWithDictKeyObject:key];
    self.mutableDictionary[internalKey] = newValue;
}

- (void)removeAllObjects
{
    [_mutableDictionary enumerateKeysAndObjectsUsingBlock:^(JFFMutableAssignDictionaryKeyWrapper *key, id obj, BOOL *stop) {
        
        [key.dictKeyObject onRemoveFromMutableAssignKeyDictionary:self];
    }];
    _mutableDictionary = nil;
}

- (NSString *)description
{
    return [_mutableDictionary?:@{} description];
}

@end
