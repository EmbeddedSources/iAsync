#import "JFFSingleThreadProxy.h"

#include "JGCDAdditions.h"

@interface JFFProxyObjectContainer : NSObject

@property ( retain, nonatomic ) id target;

@end

@implementation JFFProxyObjectContainer

@synthesize target;

@end

@interface JFFSingleThreadProxy ()

@property ( strong, nonatomic ) JFFProxyObjectContainer* container;
@property ( unsafe_unretained, nonatomic ) dispatch_queue_t dispatchQueue;

@end

@implementation JFFSingleThreadProxy

@synthesize container;
@synthesize dispatchQueue;

-(void)dealloc
{
   JFFProxyObjectContainer* container_ = self.container;
   void (^release_listener_)( void ) = ^void( void )
   {
      container_.target = nil;
   };
   dispatch_async( dispatchQueue, release_listener_ );
   dispatch_release( dispatchQueue );
}

-(id)initWithTargetFactory:( JFFObjectFactory )factory_
             dispatchQueue:( dispatch_queue_t )dispatch_queue_
{
   dispatchQueue = dispatch_queue_;
   dispatch_retain( dispatchQueue );

   factory_ = [ factory_ copy ];
   void (^release_listener_)( void ) = ^void( void )
   {
      self.container = [ JFFProxyObjectContainer new ];
      self.container.target = factory_();
   };
   dispatch_async( dispatchQueue, release_listener_ );

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
      if ( [ self.container.target respondsToSelector: selector_ ] )
         [ invocation_ invokeWithTarget: self.container.target ];
   };
   safe_dispatch_sync( dispatchQueue, forward_invocation_ );
}

-(NSMethodSignature*)methodSignatureForSelector:( SEL )selector_
{
   __block id resut_ = nil;
   void (^method_signature_)( void ) = ^void( void )
   {
      resut_ = [ self.container.target methodSignatureForSelector: selector_ ];
   };
   safe_dispatch_sync( dispatchQueue, method_signature_ );
   return resut_;
}

@end
