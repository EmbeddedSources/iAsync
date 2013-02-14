#import "JFFMulticastDelegate.h"

#import "JFFMutableAssignArray.h"

@implementation JFFMulticastDelegate
{
    JFFMutableAssignArray *_delegates;
}

- (JFFMutableAssignArray *)delegates
{
    if (!_delegates) {
        _delegates = [JFFMutableAssignArray new];
    }
    return _delegates;
}

- (void)addDelegate:(id)delegate
{
    if (![_delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id)delegate
{
    [_delegates removeObject:delegate];
}

- (void)removeAllDelegates
{
    [_delegates removeAllObjects];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    
    [_delegates enumerateObjectsUsingBlock:^void(id delegate,
                                                 NSUInteger idx,
                                                 BOOL *stop) {
        
        if ([delegate respondsToSelector:selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    __block NSMethodSignature *result;
    [_delegates enumerateObjectsUsingBlock:^void(id delegate,
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
