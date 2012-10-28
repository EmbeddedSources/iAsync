#import "NSError+ResultOwnerships.h"

#include <objc/runtime.h>

static char resultOwnershipsKey_;

@implementation NSError (ResultOwnerships)

//should not autorelease returned value
- (NSMutableArray *)resultOwnerships
{
    return objc_getAssociatedObject(self, &resultOwnershipsKey_);
}

- (NSMutableArray *)lazyResultOwnerships
{
    if (!objc_getAssociatedObject(self, &resultOwnershipsKey_)) {
        self.resultOwnerships = [ NSMutableArray new ];
    }
    return objc_getAssociatedObject(self, &resultOwnershipsKey_);
}

- (void)setResultOwnerships:(NSMutableArray *)resultOwnerships
{
    objc_setAssociatedObject(self,
                             &resultOwnershipsKey_,
                             resultOwnerships,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
