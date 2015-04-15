#import "JFFStrategyFifo.h"

#import "JFFQueueState.h"

@implementation JFFStrategyFifo

- (JFFBaseLoaderOwner *)firstPendingLoader
{
    JFFBaseLoaderOwner *result = _queueState->_pendingLoaders[0];
    return result;
}

@end
