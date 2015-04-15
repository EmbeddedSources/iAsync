#import "NSError+ResultOwnerships.h"

#include <objc/runtime.h>

static char resultOwnershipsKey;

@implementation NSError (ResultOwnerships)

//should not autorelease returned value
- (NSMutableArray *)resultOwnerships
{
    return objc_getAssociatedObject(self, &resultOwnershipsKey);
}

- (NSMutableArray *)lazyResultOwnerships
{
    if (!objc_getAssociatedObject(self, &resultOwnershipsKey)) {
        self.resultOwnerships = [NSMutableArray new];
    }
    return objc_getAssociatedObject(self, &resultOwnershipsKey);
}

- (void)setResultOwnerships:(NSMutableArray *)resultOwnerships
{
    objc_setAssociatedObject(self,
                             &resultOwnershipsKey,
                             resultOwnerships,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
