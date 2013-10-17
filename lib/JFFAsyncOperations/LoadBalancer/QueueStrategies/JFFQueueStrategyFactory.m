#import "JFFQueueStrategyFactory.h"

#import "JFFQueueState.h"
#import "JFFQueueStrategy.h"

#import "JFFStrategyFifo.h"
#import "JFFStrategyStack.h"
#import "JFFStrategyRandom.h"

@implementation JFFQueueStrategyFactory

+ (id<JFFQueueStrategy>)queueStrategyWithId:(JFFQueueExecutionOrder)strategyId
                                 queueState:(JFFQueueState *)state
{
    NSParameterAssert(strategyId >= 0);
    NSParameterAssert(strategyId <= 2);
    
    static Class strategies[3] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strategies[0] = [JFFStrategyFifo   class];
        strategies[1] = [JFFStrategyStack  class];
        strategies[2] = [JFFStrategyRandom class];
    });
    
    Class StrategyClass = strategies[ strategyId ];
    return [[StrategyClass alloc] initWithQueueState:state];
}

@end
