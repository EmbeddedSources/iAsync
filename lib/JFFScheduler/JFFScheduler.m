#import "JFFScheduler.h"

#import <JFFUtils/Extensions/NSThread+AssertMainThread.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

#include <objc/runtime.h>

char jffSchedulerKey_;

@interface NSThread (JFFScheduler)

@property ( nonatomic, strong, readonly ) JFFScheduler* jffScheduler;

@end

@implementation NSThread (JFFScheduler)

-(JFFScheduler*)jffScheduler
{
    id result_ = objc_getAssociatedObject( self, &jffSchedulerKey_ );
    if ( !result_ )
    {
        result_ = [ JFFScheduler new ];
        objc_setAssociatedObject( self
                                 , &jffSchedulerKey_
                                 , result_
                                 , OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    }
    return result_;
}

@end

@interface JFFScheduler ()

@property ( nonatomic, assign ) dispatch_queue_t queue;

@end

@implementation JFFScheduler
{
    __strong NSMutableArray* _cancelBlocks;
}

@synthesize queue;

-(void)dealloc
{
    [ self cancelAllScheduledOperations ];

    dispatch_release( queue );
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        queue = dispatch_get_current_queue();
        dispatch_retain( queue );
        _cancelBlocks = [ NSMutableArray new ];
    }

    return self;
}

+(id)sharedByThreadScheduler
{
    NSThread* thread_ = [ NSThread currentThread ];
    return thread_.jffScheduler;
}

-(JFFCancelScheduledBlock)addBlock:( JFFScheduledBlock )actionBlock_
                          duration:( NSTimeInterval )duration_
{
    NSParameterAssert( actionBlock_ );
    if ( !actionBlock_ )
        return ^(){ /* do nothing */ };

    __block dispatch_source_t timer_ = dispatch_source_create( DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue );

    int64_t delta_ = duration_ * NSEC_PER_SEC;
    dispatch_source_set_timer( timer_
                              , dispatch_time( DISPATCH_TIME_NOW, delta_ )
                              , delta_
                              , 0 );

    __unsafe_unretained JFFScheduler* self_ = self;

    JFFSimpleBlockHolder* cancelTimerBlockHolder_ = [ JFFSimpleBlockHolder new ];
    __unsafe_unretained JFFSimpleBlockHolder* weakCancelTimerBlockHolder_ = cancelTimerBlockHolder_;
    cancelTimerBlockHolder_.simpleBlock = ^void( void )
    {
        if ( !timer_ )
            return;

        dispatch_source_cancel( timer_ );
        dispatch_release( timer_ );
        timer_ = NULL;

        [ self_->_cancelBlocks removeObject: weakCancelTimerBlockHolder_.simpleBlock ];
    };

    [ _cancelBlocks addObject: cancelTimerBlockHolder_.simpleBlock ];

    actionBlock_ = [ actionBlock_ copy ];
    dispatch_block_t eventHandlerBlock_ = [ ^void( void )
    {
        actionBlock_( cancelTimerBlockHolder_.onceSimpleBlock );
    } copy ];

    dispatch_source_set_event_handler( timer_, eventHandlerBlock_ );

    dispatch_resume( timer_ );

    return cancelTimerBlockHolder_.onceSimpleBlock;
}

-(void)cancelAllScheduledOperations
{
    NSMutableSet* cancelBlocks_ = [ _cancelBlocks copy ];
    _cancelBlocks = nil;
    for ( JFFCancelScheduledBlock cancel_ in cancelBlocks_ )
        cancel_();
}

@end
