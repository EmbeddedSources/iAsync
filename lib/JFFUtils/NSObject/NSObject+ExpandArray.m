#import "NSObject+ExpandArray.h"

#import "NSObject+ProperIsKindOfClass.h"

@implementation NSArray (ExpandArray)

//TODO test
- (id)expandArray
{
    NSMutableArray *result = [NSMutableArray new];
    for (id object in self) {
        id newValue;
        if ([object properIsKindOfClass:[NSArray class]]) {
            newValue = [object expandArray];
        } else {
            newValue = self;
        }
        if ([newValue properIsKindOfClass:[NSArray class]]) {
            [result addObjectsFromArray: newValue];
        } else {
            [result addObject:newValue];
        }
    }
    return result;
}

@end

