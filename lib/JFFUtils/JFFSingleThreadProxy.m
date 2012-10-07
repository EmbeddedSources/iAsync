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

-(void)dealloc
{
    JFFProxyObjectContainer * container = self->_container;
    void (^releaseListener)(void) = ^void(void) {
        container.target = nil;
    };
    dispatch_async(self->_dispatchQueue, releaseListener);
    dispatch_release(self->_dispatchQueue);
}

- (id)initWithTargetFactory:(JFFObjectFactory)factory
              dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self->_dispatchQueue = dispatchQueue;
    dispatch_retain(self->_dispatchQueue);
    
    factory = [factory copy];
    void (^releaseListener)(void) = ^ {
        self->_container = [JFFProxyObjectContainer new];
        self->_container.target = factory();
    };
    safe_dispatch_sync(self->_dispatchQueue, releaseListener);
    
    return self;
}

+ (id)singleThreadProxyWithTargetFactory:(JFFObjectFactory)factory
                           dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    return [[self alloc]initWithTargetFactory:factory
                                dispatchQueue:dispatchQueue];
}

-(void)forwardInvocation:( NSInvocation* )invocation
{
    SEL selector = [invocation selector];
    
    void (^forwardInvocation)(void) = ^ {
        if ([self->_container.target respondsToSelector:selector])
            [invocation invokeWithTarget:self->_container.target];
    };
    safe_dispatch_sync(self->_dispatchQueue, forwardInvocation);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    __block id resut;
    void (^methodSignature)(void) = ^ {
        resut = [self->_container.target methodSignatureForSelector:selector];
    };
    safe_dispatch_sync(self->_dispatchQueue, methodSignature);
    return resut;
}

@end
