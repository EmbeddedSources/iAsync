#import "JFFMulticastDelegate.h"

#import "JFFMutableAssignArray.h"

@implementation JFFMulticastDelegate
{
    JFFMutableAssignArray *_delegates;
}

- (JFFMutableAssignArray *)delegates
{
    if (!self->_delegates) {
        self->_delegates = [JFFMutableAssignArray new];
    }
    return self->_delegates;
}

- (void)addDelegate:(id)delegate
{
    if (![self.delegates containsObject:delegate])
    {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id)delegate
{
    [self->_delegates removeObject:delegate];
}

- (void)removeAllDelegates
{
    [self->_delegates removeAllObjects];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    
    [self->_delegates enumerateObjectsUsingBlock:^void(id delegate,
                                                       NSUInteger idx,
                                                       BOOL *stop)
    {
        if ([delegate respondsToSelector:selector])
        {
            [invocation invokeWithTarget:delegate];
        }
    }];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    __block NSMethodSignature *result;
    [self->_delegates enumerateObjectsUsingBlock:^void(id delegate,
                                                       NSUInteger idx,
                                                       BOOL *stop) {
        result = [delegate methodSignatureForSelector:selector];
        if (result)
            *stop = YES;
    }];
    
    if (result)
        return result;
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)doNothing
{
}

@end
