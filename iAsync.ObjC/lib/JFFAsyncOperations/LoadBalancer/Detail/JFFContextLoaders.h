#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFContextLoaders : NSObject

@property (nonatomic) NSString *name;

@end

@interface JFFContextLoaders (ActiveLoaders)

@property (nonatomic, readonly) NSUInteger activeLoadersNumber;

- (void)addActiveNativeLoader:(JFFAsyncOperation)nativeLoader
                wrappedCancel:(JFFAsyncOperationHandler)cancel;

- (BOOL)removeActiveNativeLoader:(JFFAsyncOperation)nativeLoader;

- (void)handleActiveNativeLoader:(JFFAsyncOperation)nativeLoader
                        withTask:(JFFAsyncOperationHandlerTask)task;

@end

@class JFFPedingLoaderData;

@interface JFFContextLoaders (PendingLoaders)

@property (nonatomic, readonly) NSUInteger pendingLoadersNumber;
@property (nonatomic, readonly) BOOL hasReadyToStartPendingLoaders;

- (void)addPendingNativeLoader:(JFFAsyncOperation)nativeLoader
              progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
                 stateCallback:(JFFAsyncOperationChangeStateCallback)stateCallback
                  doneCallback:(JFFDidFinishAsyncOperationCallback)doneCallback;

- (JFFPedingLoaderData *)popNotSuspendedPendingLoaderData;

- (JFFPedingLoaderData *)pendingLoaderDataForNativeLoader:(JFFAsyncOperation)nativeLoader;

- (void)removePedingLoaderData:(JFFPedingLoaderData *)data;

@end
