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
                wrappedCancel:(JFFCancelAsyncOperation)cancel
{
    JFFActiveLoaderData *data = [JFFActiveLoaderData new];
    data.nativeLoader  = nativeLoader;
    data.wrappedCancel = cancel;
    
    [self.activeLoadersData addObject:data];
}

- (JFFActiveLoaderData*)activeLoaderDataForNativeLoader:(JFFAsyncOperation)nativeLoader
{
    return [self.activeLoadersData firstMatch:^BOOL(id object) {
        JFFActiveLoaderData *loaderData = object;
        return loaderData.nativeLoader == nativeLoader;
    }];
}

- (void)cancelActiveNativeLoader:(JFFAsyncOperation)nativeLoader cancel:(BOOL)canceled
{
    JFFActiveLoaderData *data = [self activeLoaderDataForNativeLoader:nativeLoader];
    
    if (data)
        data.wrappedCancel(canceled);
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

- (JFFPedingLoaderData *)popPendingLoaderData
{
    JFFPedingLoaderData *data = _pendingLoadersData[0];
    [_pendingLoadersData removeObjectAtIndex:0];
    if ([_pendingLoadersData count] == 0) {
        
        _pendingLoadersData = nil;
    }
    return data;
}

- (void)addPendingNativeLoader:(JFFAsyncOperation)nativeLoader
              progressCallback:(JFFAsyncOperationProgressHandler)progressCallback
                cancelCallback:(JFFCancelAsyncOperationHandler)cancelCallback
                  doneCallback:(JFFDidFinishAsyncOperationHandler)doneCallback
{
    JFFPedingLoaderData *data = [JFFPedingLoaderData new];
    data.nativeLoader     = nativeLoader;
    data.progressCallback = progressCallback;
    data.cancelCallback   = cancelCallback;
    data.doneCallback     = doneCallback;
    
    [self.pendingLoadersData addObject:data];
}

- (JFFPedingLoaderData*)pendingLoaderDataForNativeLoader:(JFFAsyncOperation)nativeLoader
{
    return [self.pendingLoadersData firstMatch:^BOOL(id object) {
        
        JFFPedingLoaderData *loaderData = object;
        return loaderData.nativeLoader == nativeLoader;
    }];
}

- (BOOL)containsPendingNativeLoader:(JFFAsyncOperation)nativeLoader
{
    return [self pendingLoaderDataForNativeLoader:nativeLoader] != nil;
}

- (void)removePendingNativeLoader:(JFFAsyncOperation)nativeLoader
{
    JFFPedingLoaderData *data = [self pendingLoaderDataForNativeLoader:nativeLoader];
    
    [_pendingLoadersData removeObject:data];
}

- (void)unsubscribePendingNativeLoader:(JFFAsyncOperation)nativeLoader
{
    JFFPedingLoaderData *data = [self pendingLoaderDataForNativeLoader:nativeLoader];
    NSAssert(data, @"pending loader data should exist" );
    
    data.progressCallback = nil;
    data.cancelCallback   = nil;
    data.doneCallback     = nil;
}

@end
