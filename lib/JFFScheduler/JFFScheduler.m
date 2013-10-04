#import "JFFScheduler.h"

#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>
#import <JFFUtils/Runtime/JFFRuntimeAddiotions.h>

@interface NSThread (JFFScheduler_Internal)

@property (nonatomic) JFFScheduler *jffScheduler;

@end

@implementation NSThread (JFFScheduler_Internal)

@dynamic jffScheduler;

+ (void)load
{
    jClass_implementProperty(self, NSStringFromSelector(@selector(jffScheduler)));
}

- (JFFScheduler *)lazyJffScheduler
{
    id result = self.jffScheduler;
    if (!result) {
        result = [JFFScheduler new];
        self.jffScheduler = result;
    }
    return result;
}

@end

@implementation JFFScheduler
{
    NSMutableArray *_cancelBlocks;
}

- (void)dealloc
{
    [self cancelAllScheduledOperations];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _cancelBlocks = [NSMutableArray new];
    }
    
    return self;
}

+ (instancetype)sharedByThreadScheduler
{
    NSThread *thread = [NSThread currentThread];
    return thread.lazyJffScheduler;
}

- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)actionBlock
                           duration:(NSTimeInterval)duration
                             leeway:(NSTimeInterval)leeway
                      dispatchQueue:(dispatch_queue_t)dispatchQueue
{
    NSParameterAssert(actionBlock);
    if (!actionBlock)
        return ^(){ /* do nothing */ };
    
    __block dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatchQueue);
    
    int64_t delta = duration * NSEC_PER_SEC;
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, delta),
                              delta,
                              leeway * NSEC_PER_SEC);
    
    __unsafe_unretained JFFScheduler *unretainedSelf = self;
    
    JFFSimpleBlockHolder *cancelTimerBlockHolder = [JFFSimpleBlockHolder new];
    __unsafe_unretained JFFSimpleBlockHolder *unretainedCancelTimerBlockHolder = cancelTimerBlockHolder;
    cancelTimerBlockHolder.simpleBlock = ^void(void) {
        if (!timer)
            return;
        
        dispatch_source_cancel(timer);
        timer = nil;
        
        [unretainedSelf->_cancelBlocks removeObject:unretainedCancelTimerBlockHolder.simpleBlock];
    };
    
    [_cancelBlocks addObject:cancelTimerBlockHolder.simpleBlock];
    
    actionBlock = [actionBlock copy];
    dispatch_block_t eventHandlerBlock = [^void(void) {
        actionBlock(cancelTimerBlockHolder.onceSimpleBlock);
    } copy];
    
    dispatch_source_set_event_handler(timer, eventHandlerBlock);
    
    dispatch_resume(timer);
    
    return cancelTimerBlockHolder.onceSimpleBlock;
}

- (JFFCancelScheduledBlock)addBlock:(JFFScheduledBlock)actionBlock
                           duration:(NSTimeInterval)duration
                             leeway:(NSTimeInterval)leeway
{
    return [self addBlock:actionBlock
                 duration:duration
                   leeway:leeway
            dispatchQueue:dispatch_get_main_queue()];
}

- (void)cancelAllScheduledOperations
{
    NSSet *cancelBlocks = [_cancelBlocks copy];
    _cancelBlocks = nil;
    for (JFFCancelScheduledBlock cancel in cancelBlocks)
        cancel();
}

@end
