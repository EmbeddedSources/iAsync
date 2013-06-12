#import "NSArray+ArrayByRemovingObject.h"

#import "NSArray+BlocksAdditions.h"

@implementation NSArray (ArrayByRemovingObject)

- (id)arrayByRemovingObjectAtIndex:(NSUInteger)index
{
    id objectToRemove = self[index];
    
    return [self arrayByRemovingObject:objectToRemove];
}

- (id)arrayByRemovingObject:(id)objectToRemove
{
    return [self select:^BOOL(id object) {
        
        return objectToRemove != object;
    }];
}

@end
