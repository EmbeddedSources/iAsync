#import "JFFScheduler.h"

#import <JFFUtils/Extensions/NSThread+AssertMainThread.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@interface JFFScheduler ()

@property ( nonatomic, retain ) NSMutableArray* cancelBlocks;
@property ( nonatomic, unsafe_unretained ) dispatch_queue_t queue;

@end

@implementation JFFScheduler

@synthesize cancelBlocks;
@synthesize queue;

-(void)dealloc
{
   [ self cancelAllScheduledOperations ];

   dispatch_release( queue );
   [ cancelBlocks release ];

   [ super dealloc ];
}

-(id)init
{
   self = [ super init ];

   if ( self )
   {
      queue = dispatch_get_current_queue();
      dispatch_retain( queue );
      self.cancelBlocks = [ NSMutableArray array ];
   }

   return self;
}

+(id)sharedScheduler
{
   [ NSThread assertMainThread ];
   static id instance_ = nil;
   if ( !instance_ )
   {
      instance_ = [ self new ];
   }
   return instance_;
}

-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )actionBlock_
                          duration:( NSTimeInterval )duration_
{
    NSParameterAssert( actionBlock_ );
    if ( !actionBlock_ )
        return [ [ ^(){ /* do nothing */ } copy ] autorelease ];

    dispatch_source_t timer_ = dispatch_source_create( DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );

    int64_t delta_ = duration_ * NSEC_PER_SEC;
    dispatch_source_set_timer( timer_
                              , dispatch_time( DISPATCH_TIME_NOW, delta_ )
                              , delta_
                              , 0 );

    __block JFFScheduler* self_ = self;

    JFFSimpleBlockHolder* cancel_timer_block_holder_ = [ [ JFFSimpleBlockHolder new ] autorelease ];
    __block JFFSimpleBlockHolder* weak_cancel_timer_block_holder_ = cancel_timer_block_holder_;
    cancel_timer_block_holder_.simpleBlock = ^void( void )
    {
        dispatch_source_cancel( timer_ );
        dispatch_release( timer_ );
        [ self_.cancelBlocks removeObject: weak_cancel_timer_block_holder_.simpleBlock ];
    };

    [ self.cancelBlocks addObject: cancel_timer_block_holder_.simpleBlock ];

    actionBlock_ = [ [ actionBlock_ copy ] autorelease ];
    dispatch_block_t event_handler_block_ = [ [ ^void( void )
    {
        actionBlock_( cancel_timer_block_holder_.onceSimpleBlock );
    } copy ] autorelease ];

    dispatch_source_set_event_handler( timer_, event_handler_block_ );

    dispatch_resume( timer_ );

    return cancel_timer_block_holder_.onceSimpleBlock;
}

-(void)cancelAllScheduledOperations
{
   NSMutableSet* cancel_blocks_ = [ self.cancelBlocks copy ];
   self.cancelBlocks = nil;
   for ( JFFCancelScheduledBlock cancel_ in cancel_blocks_ )
      cancel_();
   [ cancel_blocks_ release ];
}

@end
