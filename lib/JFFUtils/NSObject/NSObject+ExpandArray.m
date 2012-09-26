#import "NSObject+ExpandArray.h"

@implementation NSObject (ExpandArray)

//TODO test and remove -[NSObject expandArray]
- (id)expandArray
{
    return self;
}

@end

@implementation NSArray (ExpandArray)

- (id)expandArray
{
    NSMutableArray *result = [NSMutableArray new];
    for (id object in self)
    {
        id newValue = [object expandArray];
        if ([newValue isKindOfClass: [NSArray class]])
        {
            [result addObjectsFromArray: newValue];
        }
        else
        {
            [result addObject: newValue];
        }
    }
    return result;
}

@end

