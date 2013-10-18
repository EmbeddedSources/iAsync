#import "JFFStrategyStack.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@implementation JFFStrategyStack

- (JFFBaseLoaderOwner *)firstPendingLoader
{
    JFFBaseLoaderOwner *result = [_queueState->_pendingLoaders lastObject];
    return result;
}

@end
