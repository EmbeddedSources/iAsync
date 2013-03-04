#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFAsyncOperations/LoadBalancer/JFFQueueExecutionOrder.h>

#import <Foundation/Foundation.h>

@interface JFFLimitedLoadersQueue : NSObject

-(id)initWithExecutionOrder:( JFFQueueExecutionOrder )orderStrategyId;

//default value is 10
@property (nonatomic) NSUInteger limitCount;

//TODO20 immediately cancel callback
- (JFFAsyncOperation)balancedLoaderWithLoader:(JFFAsyncOperation)loader;

- (JFFAsyncOperation)barrierBalancedLoaderWithLoader:(JFFAsyncOperation)loader;

@end
