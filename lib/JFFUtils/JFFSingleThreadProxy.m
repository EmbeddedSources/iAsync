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
    JFFProxyObjectContainer* container_ = _container;
    void (^release_listener_)( void ) = ^void( void )
    {
        container_.target = nil;
    };
    dispatch_async( _dispatchQueue, release_listener_ );
    dispatch_release( _dispatchQueue );
}

-(id)initWithTargetFactory:( JFFObjectFactory )factory_
             dispatchQueue:( dispatch_queue_t )dispatch_queue_
{
    _dispatchQueue = dispatch_queue_;
    dispatch_retain( _dispatchQueue );

    factory_ = [ factory_ copy ];
    void (^release_listener_)( void ) = ^void( void )
    {
        _container = [ JFFProxyObjectContainer new ];
        _container.target = factory_();
    };
    dispatch_async( _dispatchQueue, release_listener_ );

    return self;
}

+(id)singleThreadProxyWithTargetFactory:( JFFObjectFactory )factory_
                          dispatchQueue:( dispatch_queue_t )dispatch_queue_
{
    return [ [ self alloc ] initWithTargetFactory: factory_
                                    dispatchQueue: dispatch_queue_ ];
}

-(void)forwardInvocation:( NSInvocation* )invocation_
{
    SEL selector_ = [ invocation_ selector ];

    void (^forward_invocation_)( void ) = ^void( void )
    {
        if ( [ _container.target respondsToSelector: selector_ ] )
            [ invocation_ invokeWithTarget: _container.target ];
    };
    safe_dispatch_sync( _dispatchQueue, forward_invocation_ );
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
    __block id resut_ = nil;
    void (^method_signature_)( void ) = ^void( void )
    {
        resut_ = [ _container.target methodSignatureForSelector: selector_ ];
    };
    safe_dispatch_sync( _dispatchQueue, method_signature_ );
    return resut_;
}

@end
