#import "JFFStrategyFifo.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@interface JFFStrategyFifo()
@property ( nonatomic ) JFFQueueState* queueState;
@end

@implementation JFFStrategyFifo

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(void)executePendingLoader
{
    JFFBaseLoaderOwner *pendingLoader = self->_queueState.pendingLoaders[0];
    [self->_queueState.pendingLoaders removeObjectAtIndex:0];
    [self->_queueState.activeLoaders addObject:pendingLoader];

    [pendingLoader performLoader];
}

-(id)initWithQueueState:( JFFQueueState* )queueState_
{
    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }
    
    self->_queueState = queueState_;
    
    return self;
}

@end
