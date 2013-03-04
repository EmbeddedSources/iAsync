#import <JFFAsyncOperations/LoadBalancer/JFFQueueExecutionOrder.h>
#import <Foundation/Foundation.h>

@protocol JFFQueueStrategy;
@class JFFQueueState;

@interface JFFQueueStrategyFactory : NSObject

+(id<JFFQueueStrategy>)queueStrategyWithId:( JFFQueueExecutionOrder )strategyId
                                queueState:( JFFQueueState* )state;

@end
