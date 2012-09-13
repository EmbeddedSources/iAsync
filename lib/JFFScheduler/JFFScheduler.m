#import "JFFScheduler.h"

#import <JFFUtils/Extensions/NSThread+AssertMainThread.h>
#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>

#include <objc/runtime.h>

char jffSchedulerKey;

@interface NSThread (JFFScheduler)

@property ( nonatomic, readonly ) JFFScheduler* jffScheduler;

@end

@implementation NSThread (JFFScheduler)

-(JFFScheduler*)jffScheduler
{
    id result = objc_getAssociatedObject(self, &jffSchedulerKey);
    if (!result)
    {
        result = [JFFScheduler new];
        objc_setAssociatedObject(self,
                                 &jffSchedulerKey,
                                 result,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

@end

@interface JFFScheduler ()

@property (nonatomic) dispatch_queue_t queue;

@end

@implementation JFFScheduler
{
    NSMutableArray* _cancelBlocks;
}

-(void)dealloc
{
    [ self cancelAllScheduledOperations ];

    dispatch_release( self->_queue );
}

- (id)init
{
    self = [ super init ];

    if (self)
    {
        self->_queue = dispatch_get_current_queue();
        dispatch_retain(self->_queue);
        self->_cancelBlocks = [NSMutableArray new];
    }

    return self;
}

+ (id)sharedByThreadScheduler
{
    NSThread *thread = [NSThread currentThread];
    return thread.jffScheduler;
}

- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)actionBlock
                           duration:(NSTimeInterval)duration
{
    NSParameterAssert(actionBlock);
    if (!actionBlock)
        return ^(){ /* do nothing */ };

    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self->_queue);

    int64_t delta_ = duration * NSEC_PER_SEC;
    dispatch_source_set_timer( timer
                              , dispatch_time( DISPATCH_TIME_NOW, delta_ )
                              , delta_
                              , 0 );

    __unsafe_unretained JFFScheduler* weakSelf = self;

    JFFSimpleBlockHolder* cancelTimerBlockHolder = [JFFSimpleBlockHolder new];
    __unsafe_unretained JFFSimpleBlockHolder* weakCancelTimerBlockHolder = cancelTimerBlockHolder;
    cancelTimerBlockHolder.simpleBlock = ^void( void )
    {
        if (!timer)
            return;

        dispatch_source_cancel(timer);
        dispatch_release(timer);
        timer = NULL;

        [ weakSelf->_cancelBlocks removeObject: weakCancelTimerBlockHolder.simpleBlock ];
    };

    [ self->_cancelBlocks addObject: cancelTimerBlockHolder.simpleBlock ];

    actionBlock = [actionBlock copy];
    dispatch_block_t eventHandlerBlock = [^void(void)
    {
        actionBlock(cancelTimerBlockHolder.onceSimpleBlock);
    }copy];

    dispatch_source_set_event_handler(timer, eventHandlerBlock);

    dispatch_resume(timer);

    return cancelTimerBlockHolder.onceSimpleBlock;
}

- (void)cancelAllScheduledOperations
{
    NSSet *cancelBlocks = [self->_cancelBlocks copy];
    self->_cancelBlocks = nil;
    for (JFFCancelScheduledBlock cancel in cancelBlocks)
        cancel();
}

@end
