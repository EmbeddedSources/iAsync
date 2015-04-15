#import "NSObject+Ownerships.h"

#import "NSArray+BlocksAdditions.h"

#include <objc/runtime.h>

static char ownershipsKey;

@implementation NSObject (Ownerships)

//should not autorelease returned value
- (NSMutableArray *)lazyOwnerships
{
    NSMutableArray *result = objc_getAssociatedObject(self, &ownershipsKey);
    if (!result) {
        result = [NSMutableArray new];
        objc_setAssociatedObject(self,
                                 &ownershipsKey,
                                 result,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSMutableArray *)ownerships
{
    return objc_getAssociatedObject(self, &ownershipsKey);
}

- (void)addOwnedObject:(id)object
{
    @autoreleasepool {
        [[self lazyOwnerships] addObject:object];
    }
}

- (void)removeOwnedObject:(id)object
{
    @autoreleasepool {
        [[self ownerships] removeObject:object];
    }
}

- (id)firstOwnedObjectMatch:(JFFPredicateBlock)predicate
{
    return [[self ownerships] firstMatch:predicate];
}

@end
