#import "JFFScheduler.h"

#import <JFFUtils/Extensions/NSThread+AssertMainThread.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

@interface JFFScheduler ()

//STODO move to ARC and remove inner properties
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

    __block dispatch_source_t timer_ = dispatch_source_create( DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );

    int64_t delta_ = duration_ * NSEC_PER_SEC;
    dispatch_source_set_timer( timer_
                              , dispatch_time( DISPATCH_TIME_NOW, delta_ )
                              , delta_
                              , 0 );

    __block JFFScheduler* self_ = self;

    JFFSimpleBlockHolder* cancelTimerBlockHolder_ = [ [ JFFSimpleBlockHolder new ] autorelease ];
    __block JFFSimpleBlockHolder* weak_cancel_timer_block_holder_ = cancelTimerBlockHolder_;
    cancelTimerBlockHolder_.simpleBlock = ^void( void )
    {
        if ( !timer_ )
            return;

        dispatch_source_cancel( timer_ );
        dispatch_release( timer_ );
        timer_ = NULL;

        [ self_.cancelBlocks removeObject: weak_cancel_timer_block_holder_.simpleBlock ];
    };

    [ self.cancelBlocks addObject: cancelTimerBlockHolder_.simpleBlock ];

    actionBlock_ = [ [ actionBlock_ copy ] autorelease ];
    dispatch_block_t eventHandlerBlock_ = [ [ ^void( void )
    {
        actionBlock_( cancelTimerBlockHolder_.onceSimpleBlock );
    } copy ] autorelease ];

    dispatch_source_set_event_handler( timer_, eventHandlerBlock_ );

    dispatch_resume( timer_ );

    return cancelTimerBlockHolder_.onceSimpleBlock;
}

-(void)cancelAllScheduledOperations
{
    NSMutableSet* cancelBlocks_ = [ self.cancelBlocks copy ];
    self.cancelBlocks = nil;
    for ( JFFCancelScheduledBlock cancel_ in cancelBlocks_ )
        cancel_();
    [ cancelBlocks_ release ];
}

@end
