#import "JFFSingleThreadProxy.h"

#include "JGCDAdditions.h"

@interface JFFProxyObjectContainer : NSObject

@property (nonatomic ) id target;

@end

@implementation JFFProxyObjectContainer
@end

@implementation JFFSingleThreadProxy
{
    JFFProxyObjectContainer *_container;
    dispatch_queue_t _dispatchQueue;
}

- (void)dealloc
{
    JFFProxyObjectContainer *container = _container;
    void (^releaseListener)(void) = ^void(void) {
        container.target = nil;
    };
    dispatch_async(_dispatchQueue, releaseListener);
    dispatch_release(_dispatchQueue);
}

- (instancetype)initWithTargetFactory:(JFFObjectFactory)factory
                        dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    _dispatchQueue = dispatchQueue;
    dispatch_retain(_dispatchQueue);
    
    factory = [factory copy];
    void (^releaseListener)(void) = ^ {
        _container = [JFFProxyObjectContainer new];
        _container.target = factory();
    };
    safe_dispatch_sync(_dispatchQueue, releaseListener);
    
    return self;
}

+ (instancetype)singleThreadProxyWithTargetFactory:(JFFObjectFactory)factory
                                     dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    return [[self alloc] initWithTargetFactory:factory
                                 dispatchQueue:dispatchQueue];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    
    void (^forwardInvocation)(void) = ^ {
        if ([_container.target respondsToSelector:selector])
            [invocation invokeWithTarget:_container.target];
    };
    safe_dispatch_sync(_dispatchQueue, forwardInvocation);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    __block id resut;
    void (^methodSignature)(void) = ^ {
        resut = [_container.target methodSignatureForSelector:selector];
    };
    safe_dispatch_sync(_dispatchQueue, methodSignature);
    return resut;
}

@end
