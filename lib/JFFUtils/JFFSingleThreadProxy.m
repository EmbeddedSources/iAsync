#import "JFFSingleThreadProxy.h"

#include "JGCDAdditions.h"

@interface JFFProxyObjectContainer : NSObject

@property ( retain, nonatomic ) id target;

@end

@implementation JFFProxyObjectContainer
@end

@implementation JFFSingleThreadProxy
{
    JFFProxyObjectContainer* _container;
    dispatch_queue_t _dispatchQueue;
}

-(void)dealloc
{
    JFFProxyObjectContainer* container_ = self->_container;
    void (^releaseListener_)( void ) = ^void( void )
    {
        container_.target = nil;
    };
    dispatch_async( self->_dispatchQueue, releaseListener_ );
    dispatch_release( self->_dispatchQueue );
}

- (id)initWithTargetFactory:(JFFObjectFactory)factory
              dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    self->_dispatchQueue = dispatchQueue;
    dispatch_retain(self->_dispatchQueue);

    factory = [factory copy];
    void (^releaseListener)(void) = ^void(void)
    {
        self->_container = [ JFFProxyObjectContainer new ];
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

    void (^forwardInvocation)(void) = ^void(void)
    {
        if ([self->_container.target respondsToSelector:selector])
            [invocation invokeWithTarget:self->_container.target];
    };
    safe_dispatch_sync(self->_dispatchQueue, forwardInvocation);
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
    __block id resut_ = nil;
    void (^methodSignature_)( void ) = ^void( void )
    {
        resut_ = [ self->_container.target methodSignatureForSelector: selector_ ];
    };
    safe_dispatch_sync( self->_dispatchQueue, methodSignature_ );
    return resut_;
}

@end
