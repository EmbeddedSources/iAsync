//#import "JFFSimpleBlockHolder.h"
#import "NSObject+Ownerships.h"
#import "NSObject+RuntimeExtensions.h"

#include <objc/message.h>

typedef void (^JFFNotificationCenterBlock)( NSNotification* notification_ );

@interface JFFNotificationCenterBlockHolder : NSObject

@property ( nonatomic, copy ) JFFNotificationCenterBlock block;
@property ( nonatomic, retain ) NSOperationQueue* queue;

@end

@implementation JFFNotificationCenterBlockHolder

-(void)dealloc
{
   [ self->_block release ];
   [ self->_queue release ];

   [ super dealloc ];
}

-(void)notifyBlockWithNotification:( NSNotification* )notification_
{
   if ( self.queue )
   {
      NSOperationQueue* queue_ = self.queue;
      [ queue_ addOperationWithBlock: ^void( void )
      {
         self.block( notification_ );
      } ];
      return;
   }

   self.block( notification_ );
}

-(void)removeSelfFromNotificationCenter:( NSObject* )notification_center_
{
   [ notification_center_.ownerships removeObject: self ];
}

@end

@interface NSNotificationCenterNewFeaturesRuntime : NSObject
@end

@implementation NSNotificationCenterNewFeaturesRuntime

-(void)addObserver:( id )observer_ selector:( SEL )selector_ name:( NSString* )name_ object:( id )object_
{
   [ self doesNotRecognizeSelector: _cmd ];
}

-(id)addObserverForName:( NSString* )name_
                 object:( id )object_
                  queue:( NSOperationQueue* )queue_
             usingBlock:( void (^)(NSNotification*) )block_
{
   JFFNotificationCenterBlockHolder* observer_ = [ JFFNotificationCenterBlockHolder new ];
   observer_.block = block_;
   observer_.queue = queue_;

   [ self.ownerships addObject: observer_ ];

   [ self addObserver: observer_
             selector: @selector( notifyBlockWithNotification: )
                 name: name_
               object: object_ ];

   return [ observer_ autorelease ];
}

-(void)removeObserverWithBlockHolder:( id )observer_
{
    if ( [ observer_ isKindOfClass: [ JFFNotificationCenterBlockHolder class ] ] )
    {
        JFFNotificationCenterBlockHolder* block_holder_ = observer_;
        [ block_holder_ removeSelfFromNotificationCenter: self ];
    }

    objc_msgSend( self, @selector( removeObserverWithBlockHolderNativeMethod: ), observer_ );
}

-(void)removeObserverWithBlockHolder:( id )observer_
                                name:( NSString* )name_
                              object:( id )object_
{
   if ( [ observer_ isKindOfClass: [ JFFNotificationCenterBlockHolder class ] ] )
   {
      JFFNotificationCenterBlockHolder* block_holder_ = observer_;
      [ block_holder_ removeSelfFromNotificationCenter: self ];
   }

   objc_msgSend( self, @selector( removeObserverWithBlockHolderNativeMethod:name:object: ), observer_, name_, object_ );
}

+(void)load
{
   //for ios less then 5.x only
   [ self addInstanceMethodIfNeedWithSelector: @selector( addObserverForName:object:queue:usingBlock: )
                                      toClass: [ NSURL class ] ];

   [ self hookInstanceMethodForClass: [ NSNotificationCenter class ]
                        withSelector: @selector( removeObserver: )
             prototypeMethodSelector: @selector( removeObserverWithBlockHolder: )
                  hookMethodSelector: @selector( removeObserverWithBlockHolderNativeMethod: ) ];

   [ self hookInstanceMethodForClass: [ NSNotificationCenter class ]
                        withSelector: @selector( removeObserver:name:object: )
             prototypeMethodSelector: @selector( removeObserverWithBlockHolder:name:object: )
                  hookMethodSelector: @selector( removeObserverWithBlockHolderNativeMethod:name:object: ) ];
}

@end
