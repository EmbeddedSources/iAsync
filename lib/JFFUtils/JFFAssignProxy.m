#import "JFFAssignProxy.h"

@implementation JFFAssignProxy

- (id)initWithTarget:(id)target
{
    _target = target;
    
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    
    if ([_target respondsToSelector:selector])
        [invocation invokeWithTarget:_target];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
   return [_target methodSignatureForSelector:selector];
}

@end
