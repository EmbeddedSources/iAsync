#import "NSObject+Const0.h"

@interface JFFConst0 : NSObject
@end

@implementation JFFConst0

- (void)forwardInvocation:(NSInvocation *)invocation
{
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (NSUInteger)doNothing
{
    return 0;
}

@end

@implementation NSObject (Const0)

+ (id)objectThatAlwaysReturnsZeroForAnyMethod
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{ instance = [JFFConst0 new]; });
    return instance;
}

@end
