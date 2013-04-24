#import "JFFStrategyFifo.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@implementation JFFStrategyFifo

- (void)executePendingLoader
{
    JFFBaseLoaderOwner *pendingLoader = _queueState->_pendingLoaders[0];
    [_queueState->_pendingLoaders removeObjectAtIndex:0];
    [_queueState->_activeLoaders addObject:pendingLoader];
    
    [self executePendingLoader:pendingLoader];
}

@end
