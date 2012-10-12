#import <JFFUtils/Blocks/JUContainersHelperBlocks.h>

#import <Foundation/Foundation.h>

@interface NSObject (Ownerships)

//lazy load property, any object can be added to this array
- (void)addOwnedObject:(id)object;

- (void)removeOwnedObject:(id)object;

- (id)firstOwnedObjectMatch:(JFFPredicateBlock)predicate;

@end
