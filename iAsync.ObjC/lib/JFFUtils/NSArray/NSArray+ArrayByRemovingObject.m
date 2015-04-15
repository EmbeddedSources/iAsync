#import "NSArray+ArrayByRemovingObject.h"

#import "NSArray+BlocksAdditions.h"

@implementation NSArray (ArrayByRemovingObject)

- (instancetype)arrayByRemovingObjectAtIndex:(NSUInteger)index
{
    id objectToRemove = self[index];
    
    return [self arrayByRemovingObject:objectToRemove];
}

- (instancetype)arrayByRemovingObject:(id)objectToRemove
{
    return [self filter:^BOOL(id object) {
        
        return objectToRemove != object;
    }];
}

@end
