#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFContextLoaders : NSObject

@property ( nonatomic, retain ) NSString* name;

@end

@interface JFFContextLoaders ( ActiveLoaders )

@property ( nonatomic, readonly ) NSUInteger activeLoadersNumber;

-(void)addActiveNativeLoader:( JFFAsyncOperation )native_loader_
               wrappedCancel:( JFFCancelAsyncOperation )cancel_;

-(BOOL)removeActiveNativeLoader:( JFFAsyncOperation )native_loader_;

-(void)cancelActiveNativeLoader:( JFFAsyncOperation )native_loader_ cancel:( BOOL )canceled_;

@end

@class JFFPedingLoaderData;

@interface JFFContextLoaders ( PendingLoaders )

@property ( nonatomic, readonly ) NSUInteger pendingLoadersNumber;

-(JFFPedingLoaderData*)popPendingLoaderData;

-(void)addPendingNativeLoader:( JFFAsyncOperation )native_loader_
             progressCallback:( JFFAsyncOperationProgressHandler )progress_callback_
               cancelCallback:( JFFCancelAsyncOperationHandler )cancel_callback_
                 doneCallback:( JFFDidFinishAsyncOperationHandler )done_callback_;

-(BOOL)containsPendingNativeLoader:( JFFAsyncOperation )native_loader_;

-(void)removePendingNativeLoader:( JFFAsyncOperation )native_loader_;

-(void)unsubscribePendingNativeLoader:( JFFAsyncOperation )native_loader_;

@end
