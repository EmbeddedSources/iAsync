#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface JFFMutableAssignArray : NSObject

@property (nonatomic, copy, readonly) NSArray *array;
@property (nonatomic, copy) JFFSimpleBlock onRemoveObject;

//compare elements by pointers only
- (void)addObject:(id)object;
- (BOOL)containsObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeAllObjects;

- (NSUInteger)count;

- (id)firstMatch:(JFFPredicateBlock)predicate;
- (void)enumerateObjectsUsingBlock:(void(^)(id obj, NSUInteger idx, BOOL *stop))block;

- (id)lastObject;

- (BOOL)any:(JFFPredicateBlock)predicate;
- (BOOL)all:(JFFPredicateBlock)predicate;

@end
