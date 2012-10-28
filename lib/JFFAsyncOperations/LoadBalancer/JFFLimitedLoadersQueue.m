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
    return _limitCount > [_activeLoaders count] && [_pendingLoaders count] > 0;
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
{
    loader = [loader copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFBaseLoaderOwner *loaderHolder =
        [JFFBaseLoaderOwner newLoaderOwnerWithLoader:loader
                                               queue:self];
        
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

- (void)didFinishedActiveLoader:(JFFBaseLoaderOwner *)activeLoader
{
    [_activeLoaders removeObject:activeLoader];
    [self performPendingLoaders];
}

@end
