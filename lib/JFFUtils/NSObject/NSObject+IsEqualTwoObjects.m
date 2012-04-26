#import "NSObject+IsEqualTwoObjects.h"

@implementation NSObject (IsEqualTwoObjects)

+(BOOL)object:( NSObject* )object1_
    isEqualTo:( NSObject* )object2_
{
    if ( nil == object1_ && nil == object2_ )
        return YES;

    return [ object1_ isEqual: object2_ ];
}

@end
