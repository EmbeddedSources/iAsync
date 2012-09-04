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

-(id)initWithTargetFactory:( JFFObjectFactory )factory_
             dispatchQueue:( dispatch_queue_t )dispatchQueue_
{
    self->_dispatchQueue = dispatchQueue_;
    dispatch_retain( self->_dispatchQueue );

    factory_ = [ factory_ copy ];
    void (^releaseListener_)( void ) = ^void( void )
    {
        self->_container = [ JFFProxyObjectContainer new ];
        self->_container.target = factory_();
    };
    dispatch_async( self->_dispatchQueue, releaseListener_ );

    return self;
}

+(id)singleThreadProxyWithTargetFactory:( JFFObjectFactory )factory_
                          dispatchQueue:( dispatch_queue_t )dispatchQueue_
{
    return [ [ self alloc ] initWithTargetFactory: factory_
                                    dispatchQueue: dispatchQueue_ ];
}

-(void)forwardInvocation:( NSInvocation* )invocation_
{
    SEL selector_ = [ invocation_ selector ];

    void (^forward_invocation_)( void ) = ^void( void )
    {
        if ( [ self->_container.target respondsToSelector: selector_ ] )
            [ invocation_ invokeWithTarget: self->_container.target ];
    };
    safe_dispatch_sync( self->_dispatchQueue, forward_invocation_ );
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
