#import "JFFBaseStrategy.h"

#import "JFFBaseLoaderOwner.h"

@implementation JFFBaseStrategy

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithQueueState:(JFFQueueState *)queueState
{
    self = [super init];
    
    if (self) {
        _queueState = queueState;
    }
    
    return self;
}

- (void)executePendingLoader:(JFFBaseLoaderOwner *)pendingLoader
{
#ifdef DEBUG
    NSUInteger pendingLoadersCount = [_queueState.pendingLoaders count];
    NSUInteger activeLoadersCount  = [_queueState.activeLoaders  count];
#endif //DEBUG
    
    [pendingLoader performLoader];
    
#ifdef DEBUG
    NSParameterAssert(pendingLoadersCount >= [_queueState.pendingLoaders count]);
    NSParameterAssert(activeLoadersCount  >= [_queueState.activeLoaders  count]);
#endif //DEBUG
}

@end
