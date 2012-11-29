#import "JFFMutableAssignArray.h"

#import "JFFAssignProxy.h"

#import "NSArray+BlocksAdditions.h"
#import "NSObject+OnDeallocBlock.h"

#include "JFFUtilsBlockDefinitions.h"

#import "JFFClangLiterals.h"

@interface JFFAutoRemoveAssignProxy : JFFAssignProxy

@property (nonatomic, copy) JFFSimpleBlock onDeallocBlock;

@end

@implementation JFFAutoRemoveAssignProxy

- (void)onAddToMutableAssignArray:(JFFMutableAssignArray *)array
{
    __unsafe_unretained JFFMutableAssignArray    *unretainedArray = array;
    __unsafe_unretained JFFAutoRemoveAssignProxy *unretainedSelf  = self;
    self.onDeallocBlock = ^void(void) {
        [unretainedArray removeObject:unretainedSelf.target];
    };
    [self.target addOnDeallocBlock:self.onDeallocBlock];
}

- (void)onRemoveFromMutableAssignArray:(JFFMutableAssignArray *)array
{
    [self.target removeOnDeallocBlock:self->_onDeallocBlock];
    self->_onDeallocBlock = nil;
}

@end

@interface JFFMutableAssignArray ()

@property (nonatomic) NSMutableArray* mutableArray;

@end

@implementation JFFMutableAssignArray

@dynamic array;

- (void)dealloc
{
    [self removeAllObjects];
}

- (NSMutableArray *)mutableArray
{
    if (!self->_mutableArray) {
        self->_mutableArray = [@[] mutableCopy];
    }
    return self->_mutableArray;
}

- (NSArray *)array
{
    return [self->_mutableArray map:^id(JFFAutoRemoveAssignProxy *proxy) {
        return proxy.target;
    }];
}

- (void)addObject:(id)object
{
    JFFAutoRemoveAssignProxy* proxy = [[JFFAutoRemoveAssignProxy alloc] initWithTarget:object];
    [self.mutableArray addObject:proxy];
    [proxy onAddToMutableAssignArray:self];
}

- (BOOL)containsObject:(id)object
{
    return [self->_mutableArray any:^BOOL(id element) {
        JFFAutoRemoveAssignProxy *proxy = element;
        return proxy.target == object;
    }];
}

- (void)removeObject:(id)object
{
    NSUInteger index = [self->_mutableArray firstIndexOfObjectMatch:^BOOL(id element) {
        JFFAutoRemoveAssignProxy *proxy = element;
        return proxy.target == object;
    }];
    
    if (index != NSNotFound) {
        JFFAutoRemoveAssignProxy *proxy = self->_mutableArray[index];
        [proxy onRemoveFromMutableAssignArray:self];
        [self->_mutableArray removeObjectAtIndex:index];
    }
    
    if (_onRemoveObject) {
        _onRemoveObject();
    }
}

- (void)removeAllObjects
{
    for (JFFAutoRemoveAssignProxy *proxy in self->_mutableArray) {
        [proxy onRemoveFromMutableAssignArray:self];
    }
    [self->_mutableArray removeAllObjects];
}

- (NSUInteger)count
{
    return [self->_mutableArray count];
}

- (id)initWithObject:( id )anObject
{
    self = [super init];
    
    [self addObject:anObject];
    
    return self;
}

- (id)firstMatch:(JFFPredicateBlock)predicate
{
    for (JFFAutoRemoveAssignProxy *proxy in self->_mutableArray) {
        if (predicate(proxy.target))
            return proxy.target;
    }
    return nil;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id, NSUInteger, BOOL *))block
{
    [self->_mutableArray enumerateObjectsUsingBlock:^void(JFFAutoRemoveAssignProxy *proxy,
                                                          NSUInteger midx,
                                                          BOOL *mstop) {
        block(proxy.target, midx, mstop);
    }];
}

- (id)lastObject
{
    JFFAutoRemoveAssignProxy *proxy = [self->_mutableArray lastObject];
    return proxy.target;
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
