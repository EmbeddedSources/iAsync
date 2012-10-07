#import "NSOrderedSet+NoThrowObjectAtIndex.h"

@implementation NSOrderedSet (NoThrowObjectAtIndex)

//TODO fix duplicate code
- (id)noThrowObjectAtIndex:(NSUInteger)index
{
    if ([self count] <= index)
        return nil;
    
    return [self objectAtIndex:index];
}

@end
