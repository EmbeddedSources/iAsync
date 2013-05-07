#import "JFFStrategyRandom.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@implementation JFFStrategyRandom

- (JFFBaseLoaderOwner *)firstPendingLoader
{
    int index = rand() % [_queueState->_pendingLoaders count];
    NSUInteger castedIndex = static_cast<NSUInteger>(index);
    
    JFFBaseLoaderOwner *result = _queueState->_pendingLoaders[castedIndex];
    return result;
}

@end
