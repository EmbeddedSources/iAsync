#import "NSThread+AsyncPropertyReader.h"

#include <objc/runtime.h>

static char _loaderMergeObjectKey;

@implementation NSThread (AsyncPropertyReader)

- (NSObject *)lazyLoaderMergeObject
{
    id result = objc_getAssociatedObject(self, &_loaderMergeObjectKey);
    if (!result) {
        result = [NSObject new];
        objc_setAssociatedObject(self,
                                 &_loaderMergeObjectKey,
                                 result,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

@end
