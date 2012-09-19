#import "NSObject+Ownerships.h"

#include <objc/runtime.h>

static char ownershipsKey;

@implementation NSObject (Ownerships)

//should not autorelease returned value
- (NSMutableArray *)ownerships
{
    if (!objc_getAssociatedObject(self, &ownershipsKey))
    {
        objc_setAssociatedObject(self, &ownershipsKey,[NSMutableArray new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objc_getAssociatedObject(self, &ownershipsKey);
}

@end
