#import <Foundation/Foundation.h>

@interface NSArray (ArrayByRemovingObject)

- (instancetype)arrayByRemovingObjectAtIndex:(NSUInteger)index;

- (instancetype)arrayByRemovingObject:(id)objectToRemove;

@end
