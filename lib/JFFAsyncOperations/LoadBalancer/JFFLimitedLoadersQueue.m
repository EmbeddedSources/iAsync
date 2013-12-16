#import "JFFLimitedLoadersQueue.h"

#import "JFFBaseLoaderOwner.h"
#import "JFFQueueStrategy.h"
#import "JFFQueueStrategyFactory.h"
#import "JFFQueueState.h"

@implementation JFFLimitedLoadersQueue
{
    NSMutableArray *_activeLoaders;
    NSMutableArray *_pendingLoaders;
    
    id<JFFQueueStrategy> _orderStrategy;
}

- (instancetype)initWithExecutionOrder:(JFFQueueExecutionOrder)orderStrategyId
{
    self = [super init];
    
    if (self) {
        
        _limitCount     = 10;
        _activeLoaders  = [NSMutableArray new];
        _pendingLoaders = [NSMutableArray new];
        
        JFFQueueState *state = [JFFQueueState new];
        state->_activeLoaders  = _activeLoaders ;
        state->_pendingLoaders = _pendingLoaders;
        
        _orderStrategy = [JFFQueueStrategyFactory queueStrategyWithId:orderStrategyId
                                                           queueState:state];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithExecutionOrder:JQOrderFifo];
}

- (BOOL)hasLoadersReadyToStartForPendingLoader:(JFFBaseLoaderOwner *)pendingLoader
{
    if (pendingLoader.barrier) {
        
        return [_activeLoaders count] == 0;
    }
    
    BOOL result = _limitCount > [_activeLoaders count] && [_pendingLoaders count] > 0;
    
    if (result) {
        
        result = [_activeLoaders all:^BOOL(JFFBaseLoaderOwner *activeLoader) {
            return !activeLoader.barrier;
        }];
    }
    
    return result;
}

- (JFFBaseLoaderOwner *)nextPendingLoader
{
    JFFBaseLoaderOwner *result = ([_pendingLoaders count] > 0)
    ?[_orderStrategy firstPendingLoader]
    :nil;
    
    return result;
}

- (void)performPendingLoaders
{
    JFFBaseLoaderOwner *pendingLoader = [self nextPendingLoader];
    
    while (pendingLoader && [self hasLoadersReadyToStartForPendingLoader:pendingLoader]) {
        
        [_orderStrategy executePendingLoader:pendingLoader];
        pendingLoader = [self nextPendingLoader];
    }
}

- (void)setLimitCount:(NSUInteger)limitCount
{
    _limitCount = limitCount;
    
    [self performPendingLoaders];
}

- (JFFAsyncOperation)balancedLoaderWithLoader:(JFFAsyncOperation)loader
                                      barrier:(BOOL)barrier
{
    loader = [loader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFBaseLoaderOwner *loaderHolder =
        [JFFBaseLoaderOwner newLoaderOwnerWithLoader:loader
                                               queue:self];
        loaderHolder.barrier = barrier;
        
        loaderHolder.progressCallback = progressCallback;
        loaderHolder.cancelCallback   = cancelCallback;
        loaderHolder.doneCallback     = doneCallback;
        
        [_pendingLoaders addObject:loaderHolder];
        
        [self performPendingLoaders];
        
        __weak JFFBaseLoaderOwner *weakLoaderHolder = loaderHolder;
        
        return ^(BOOL canceled) {
            
            JFFBaseLoaderOwner *loaderHolder = weakLoaderHolder;
            if (!loaderHolder)
                return;
            
            JFFCancelAsyncOperationHandler cancelCallback = loaderHolder.cancelCallback;
            
            if (canceled) {
                if (!loaderHolder.cancelLoader) {
                    //TODO self owning here fix?
                    [_pendingLoaders removeObject:loaderHolder];
                }
            } else {
                loaderHolder.progressCallback = nil;
                loaderHolder.cancelCallback   = nil;
                loaderHolder.doneCallback     = nil;
            }
            
            if (loaderHolder.cancelLoader) {
                loaderHolder.cancelLoader(YES);
            } else if (cancelCallback) {
                cancelCallback(canceled);
            }
        };
    };
}

- (JFFAsyncOperation)balancedLoaderWithLoader:(JFFAsyncOperation)loader
{
    return [self balancedLoaderWithLoader:loader barrier:NO];
}

- (JFFAsyncOperation)barrierBalancedLoaderWithLoader:(JFFAsyncOperation)loader
{
    return [self balancedLoaderWithLoader:loader barrier:YES];
}

- (void)didFinishActiveLoader:(JFFBaseLoaderOwner *)activeLoader
{
    [_activeLoaders removeObject:activeLoader];
    [self performPendingLoaders];
}

@end
