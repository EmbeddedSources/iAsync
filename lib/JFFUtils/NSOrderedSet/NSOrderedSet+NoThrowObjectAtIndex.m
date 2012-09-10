#import "NSOrderedSet+NoThrowObjectAtIndex.h"

@implementation NSOrderedSet (NoThrowObjectAtIndex)

-(id)noThrowObjectAtIndex:( NSUInteger )index_
{
    if ( [ self count ] <= index_ )
        return nil;
    
    return [self objectAtIndex:index_];
}


@end
