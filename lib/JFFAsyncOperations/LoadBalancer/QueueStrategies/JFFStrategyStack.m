#import "JFFStrategyStack.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@implementation JFFStrategyStack

-(void)executePendingLoader
{
    JFFBaseLoaderOwner *pendingLoader = [_queueState->_pendingLoaders lastObject];
    [_queueState->_pendingLoaders removeLastObject];
    [_queueState->_activeLoaders  addObject:pendingLoader];
    
    [self executePendingLoader:pendingLoader];
}

@end
