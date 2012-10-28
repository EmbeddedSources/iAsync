#import "NSOrderedSet+NoThrowObjectAtIndex.h"

@implementation NSOrderedSet (NoThrowObjectAtIndex)

//TODO fix duplicate code
- (id)noThrowObjectAtIndex:(NSUInteger)index
{
    if ([self count] <= index)
        return nil;
    
    //has no method objectAtIndexedSubscript
    return [self objectAtIndex:index];
}

@end
