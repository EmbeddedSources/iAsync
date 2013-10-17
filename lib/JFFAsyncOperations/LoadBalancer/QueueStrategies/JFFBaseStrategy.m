#import "JFFBaseStrategy.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@implementation JFFBaseStrategy

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithQueueState:(JFFQueueState *)queueState
{
    self = [super init];
    
    if (self) {
        _queueState = queueState;
    }
    
    return self;
}

- (void)executePendingLoader:(JFFBaseLoaderOwner *)pendingLoader
{
    [_queueState->_pendingLoaders removeObject:pendingLoader];
    [_queueState->_activeLoaders  addObject:pendingLoader];
    
#ifdef DEBUG
    NSUInteger pendingLoadersCount = [_queueState->_pendingLoaders count];
    NSUInteger activeLoadersCount  = [_queueState->_activeLoaders  count];
#endif //DEBUG
    
    [pendingLoader performLoader];
    
#ifdef DEBUG
    NSParameterAssert(pendingLoadersCount >= [_queueState->_pendingLoaders count]);
    NSParameterAssert(activeLoadersCount  >= [_queueState->_activeLoaders  count]);
#endif //DEBUG
}

@end
