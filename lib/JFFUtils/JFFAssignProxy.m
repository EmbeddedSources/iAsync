#import "JFFAssignProxy.h"

@implementation JFFAssignProxy

- (id)initWithTarget:(id)target
{
    self->_target = target;

    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];

    if ([self->_target respondsToSelector:selector])
        [invocation invokeWithTarget:self->_target];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
   return [self->_target methodSignatureForSelector:selector];
}

@end
