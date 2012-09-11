#import <JFFUtils/NSArray/JUArrayHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface JFFMutableAssignArray : NSObject

@property (nonatomic, copy, readonly) NSArray *array;

//compare elements by pointers only
- (void)addObject:(id)object;
- (BOOL)containsObject:(id)object;
- (void)removeObject:(id)object;
- (void)removeAllObjects;

-(NSUInteger)count;

- (id)firstMatch:(JFFPredicateBlock)predicate;
- (void)enumerateObjectsUsingBlock:(void(^)(id obj, NSUInteger idx, BOOL *stop))block;

//TODO test it
- (id)lastObject;

@end
