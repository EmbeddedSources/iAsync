#import "JFFLimitedLoadersQueue.h"

#import "JFFBaseLoaderOwner.h"

@implementation JFFLimitedLoadersQueue
{
    NSMutableArray *_activeLoaders;
    NSMutableArray *_pendingLoaders;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _limitCount     = 10;
        _activeLoaders  = [NSMutableArray new];
        _pendingLoaders = [NSMutableArray new];
    }
    
    return self;
}

- (BOOL)hasLoadersReadyToStart
{
    if ([_pendingLoaders count] > 0) {
        
        JFFBaseLoaderOwner *pendingLoader = _pendingLoaders[0];
        if (pendingLoader.barrier) {
            
            return [_activeLoaders count] == 0;
        }
    }
    
    BOOL result = _limitCount > [_activeLoaders count] && [_pendingLoaders count] > 0;
    
    if (result) {
        
        result = [_activeLoaders all:^BOOL(JFFBaseLoaderOwner *activeLoader) {
            return !activeLoader.barrier;
        }];
    }
    
    return result;
}

- (void)performPendingLoaders
{
    while ([self hasLoadersReadyToStart]) {
        
        JFFBaseLoaderOwner *pendingLoader = _pendingLoaders[0];
        [_pendingLoaders removeObjectAtIndex:0];
        
        [_activeLoaders addObject:pendingLoader];
        
        [pendingLoader performLoader];
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
            if (weakLoaderHolder) {
                
                JFFCancelAsyncOperationHandler cancelCallback = weakLoaderHolder.cancelCallback;
                
                if (canceled) {
                    if (!weakLoaderHolder.cancelLoader)
                        [_pendingLoaders removeObject:weakLoaderHolder];
                } else {
                    weakLoaderHolder.progressCallback = nil;
                    weakLoaderHolder.cancelCallback   = nil;
                    weakLoaderHolder.doneCallback     = nil;
                }
                
                if (weakLoaderHolder.cancelLoader) {
                    weakLoaderHolder.cancelLoader(YES);
                } else if (cancelCallback) {
                    cancelCallback(canceled);
                }
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

- (void)didFinishedActiveLoader:(JFFBaseLoaderOwner *)activeLoader
{
    [_activeLoaders removeObject:activeLoader];
    [self performPendingLoaders];
}

@end
