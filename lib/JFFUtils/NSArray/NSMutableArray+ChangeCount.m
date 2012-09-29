#import "NSMutableArray+ChangeCount.h"

@implementation NSMutableArray (ChangeCount)

- (void)shrinkToSize:(NSUInteger)newSize
{
    NSUInteger count = [self count];
    
    if (count <= newSize) {
        //The size already fits
        return;
    }
    
    NSRange range = {0, newSize};
    [self setArray:[self subarrayWithRange:range]];
}

@end
