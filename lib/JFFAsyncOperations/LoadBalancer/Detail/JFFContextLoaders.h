#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFContextLoaders : NSObject

@property (nonatomic) NSString *name;

@end

@interface JFFContextLoaders ( ActiveLoaders )

@property (nonatomic, readonly) NSUInteger activeLoadersNumber;

- (void)addActiveNativeLoader:(JFFAsyncOperation)nativeLoader
                wrappedCancel:(JFFCancelAsyncOperation)cancel;

- (BOOL)removeActiveNativeLoader:(JFFAsyncOperation)nativeLoader;

- (void)cancelActiveNativeLoader:(JFFAsyncOperation)nativeLoader cancel:(BOOL)canceled;

@end

@class JFFPedingLoaderData;

@interface JFFContextLoaders ( PendingLoaders )

@property (nonatomic, readonly) NSUInteger pendingLoadersNumber;

- (JFFPedingLoaderData *)popPendingLoaderData;

- (void)addPendingNativeLoader:(JFFAsyncOperation)nativeLoader
              progressCallback:(JFFAsyncOperationProgressHandler)progressCallback
                cancelCallback:(JFFCancelAsyncOperationHandler)cancelCallback
                  doneCallback:(JFFDidFinishAsyncOperationHandler)doneCallback;

- (BOOL)containsPendingNativeLoader:(JFFAsyncOperation)nativeLoader;

- (void)removePendingNativeLoader:(JFFAsyncOperation)nativeLoader;

- (void)unsubscribePendingNativeLoader:(JFFAsyncOperation)nativeLoader;

@end
