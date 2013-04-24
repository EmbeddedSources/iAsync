#import "JFFStrategyRandom.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@implementation JFFStrategyRandom

- (void)executePendingLoader
{
    int index = rand() % [_queueState->_pendingLoaders count];
    NSUInteger castedIndex = static_cast<NSUInteger>(index);
    
    JFFBaseLoaderOwner *pendingLoader = _queueState->_pendingLoaders[castedIndex];
    [_queueState->_pendingLoaders removeObjectAtIndex:castedIndex];
    [_queueState->_activeLoaders addObject:pendingLoader];
    
    [self executePendingLoader:pendingLoader];
}

@end
