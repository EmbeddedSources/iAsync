#import "NSOrderedSet+BlocksAdditions.h"

@implementation NSOrderedSet (BlocksAdditions)

//TODO test
//TODO remove code duplicate
- (NSOrderedSet *)map:(JFFMappingBlock)block
{
    NSMutableOrderedSet *result = [[NSMutableOrderedSet alloc] initWithCapacity:[self count]];
    
    for (id object in self) {
        id newObject = block(object);
        NSParameterAssert(newObject);
        [result addObject:newObject];
    }
    
    return [result copy];
}

@end
