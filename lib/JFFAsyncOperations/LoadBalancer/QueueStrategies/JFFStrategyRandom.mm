#import "JFFStrategyRandom.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@interface JFFStrategyRandom()
@property ( nonatomic ) JFFQueueState* queueState;
@end



@implementation JFFStrategyRandom

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(void)executePendingLoader
{
    int index = rand() % [ self->_queueState.pendingLoaders count ];
    NSUInteger castedIndex = static_cast<NSUInteger>(index);
    
    JFFBaseLoaderOwner *pendingLoader = self->_queueState.pendingLoaders[castedIndex];
    [self->_queueState.pendingLoaders removeObjectAtIndex:castedIndex];
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
