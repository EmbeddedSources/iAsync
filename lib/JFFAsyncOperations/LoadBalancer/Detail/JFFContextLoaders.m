#import "JFFContextLoaders.h"

#import "JFFActiveLoaderData.h"
#import "JFFPedingLoaderData.h"

@implementation JFFContextLoaders
{
    NSMutableArray *_activeLoadersData;
    NSMutableArray *_pendingLoadersData;
}

- (NSMutableArray *)activeLoadersData
{
    if (!_activeLoadersData) {
        _activeLoadersData = [NSMutableArray new];
    }
    return _activeLoadersData;
}

- (NSMutableArray *)pendingLoadersData
{
    if (!_pendingLoadersData) {
        _pendingLoadersData = [NSMutableArray new];
    }
    return _pendingLoadersData;
}

@end

@implementation JFFContextLoaders (ActiveLoaders)

- (NSUInteger)activeLoadersNumber
{
    return [_activeLoadersData count];
}

- (void)addActiveNativeLoader:(JFFAsyncOperation)nativeLoader
                wrappedCancel:(JFFAsyncOperationHandler)cancel
{
    JFFActiveLoaderData *data = [JFFActiveLoaderData new];
    data.nativeLoader   = nativeLoader;
    data.wrappedHandler = cancel;
    
    [self.activeLoadersData addObject:data];
}

- (JFFActiveLoaderData*)activeLoaderDataForNativeLoader:(JFFAsyncOperation)nativeLoader
{
    return [self.activeLoadersData firstMatch:^BOOL(id object) {
        JFFActiveLoaderData *loaderData = object;
        return loaderData.nativeLoader == nativeLoader;
    }];
}

- (void)handleActiveNativeLoader:(JFFAsyncOperation)nativeLoader
                        withTask:(JFFAsyncOperationHandlerTask)task
{
    JFFActiveLoaderData *data = [self activeLoaderDataForNativeLoader:nativeLoader];
    
    if (data)
        data.wrappedHandler(task);
}

- (BOOL)removeActiveNativeLoader:(JFFAsyncOperation)nativeLoader
{
    JFFActiveLoaderData *data = [self activeLoaderDataForNativeLoader:nativeLoader];
    
    if (data) {
        [self.activeLoadersData removeObject:data];
        return YES;
    }

    return NO;
}

@end

@implementation JFFContextLoaders ( PendingLoaders )

- (NSUInteger)pendingLoadersNumber
{
    return [_pendingLoadersData count];
}

- (BOOL)hasReadyToStartPendingLoaders
{
    return [_pendingLoadersData any:^BOOL(JFFPedingLoaderData *data) {
        
        return !data.suspended;
    }];
}

- (JFFPedingLoaderData *)popPendingLoaderDataWithPredicate:(JFFPredicateBlock)predicate
{
    NSUInteger index = [_pendingLoadersData indexOfObjectPassingTest:^BOOL(JFFPedingLoaderData *data, NSUInteger idx, BOOL *stop) {
        
        return predicate(data);
    }];
    
    if (index == NSNotFound)
        return nil;
    
    JFFPedingLoaderData *data = _pendingLoadersData[index];
    [_pendingLoadersData removeObjectAtIndex:index];
    if ([_pendingLoadersData count] == 0) {
        
        _pendingLoadersData = nil;
    }
    return data;
}

- (JFFPedingLoaderData *)popNotSuspendedPendingLoaderData
{
    JFFPedingLoaderData *data = [self popPendingLoaderDataWithPredicate:^BOOL(JFFPedingLoaderData *data) {
        
        return !data.suspended;
    }];
    
    NSAssert(data != nil, @"invalid state preconditions for popNotSuspendedPendingLoaderData");
    return data;
}

- (void)addPendingNativeLoader:(JFFAsyncOperation)nativeLoader
              progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
                 stateCallback:(JFFAsyncOperationChangeStateCallback)stateCallback
                  doneCallback:(JFFDidFinishAsyncOperationCallback)doneCallback
{
    JFFPedingLoaderData *data = [JFFPedingLoaderData new];
    data.nativeLoader     = nativeLoader    ;
    data.progressCallback = progressCallback;
    data.stateCallback    = stateCallback   ;
    data.doneCallback     = doneCallback    ;
    
    [self.pendingLoadersData addObject:data];
}

- (JFFPedingLoaderData *)pendingLoaderDataForNativeLoader:(JFFAsyncOperation)nativeLoader
{
    return [self.pendingLoadersData firstMatch:^BOOL(id object) {
        
        JFFPedingLoaderData *loaderData = object;
        return loaderData.nativeLoader == nativeLoader;
    }];
}

- (void)removePedingLoaderData:(JFFPedingLoaderData *)data
{
    [_pendingLoadersData removeObject:data];
}

@end
