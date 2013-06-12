#import <Foundation/Foundation.h>

@interface NSArray (ArrayByRemovingObject)

- (id)arrayByRemovingObjectAtIndex:(NSUInteger)index;

- (id)arrayByRemovingObject:(id)objectToRemove;

@end
