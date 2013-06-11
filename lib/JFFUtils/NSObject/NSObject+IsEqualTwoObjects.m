#import "NSObject+IsEqualTwoObjects.h"

@implementation NSObject (IsEqualTwoObjects)

+ (BOOL)object:(NSObject *)object1
     isEqualTo:(NSObject *)object2
{
    if (nil == object1 && nil == object2)
        return YES;
    
    return [object1 isEqual:object2];
}

@end
