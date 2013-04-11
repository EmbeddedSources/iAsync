#import "JFFStrategyStack.h"

#import "JFFQueueState.h"
#import "JFFBaseLoaderOwner.h"

@interface JFFStrategyStack()
@property ( nonatomic ) JFFQueueState* queueState;
@end


@implementation JFFStrategyStack

-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(void)executePendingLoader
{
    JFFBaseLoaderOwner *pendingLoader = [ self->_queueState.pendingLoaders lastObject ];
    [self->_queueState.pendingLoaders removeLastObject];
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
