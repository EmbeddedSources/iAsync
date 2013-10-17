#import "NSObject+ExpandArray.h"

#import "NSObject+JFFMeaningClass.h"

@implementation NSArray (ExpandArray)

- (instancetype)expandArray
{
    NSMutableArray *result = [NSMutableArray new];
    for (id object in self) {
        id newValue;
        Class objectClass = [object jffMeaningClass];
        if ([objectClass isSubclassOfClass:[NSArray class]]) {
            newValue = [object expandArray];
        } else {
            newValue = object;
        }
        Class newValueClass = [newValue jffMeaningClass];
        if ([newValueClass isSubclassOfClass:[NSArray class]]) {
            [result addObjectsFromArray:newValue];
        } else {
            [result addObject:newValue];
        }
    }
    return [result copy];
}

@end

