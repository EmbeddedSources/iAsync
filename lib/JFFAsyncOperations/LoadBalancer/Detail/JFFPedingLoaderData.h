#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFPedingLoaderData : NSObject

@property (nonatomic, copy) JFFAsyncOperation nativeLoader;
@property (nonatomic, copy) JFFAsyncOperationProgressCallback progressCallback;
@property (nonatomic, copy) JFFAsyncOperationChangeStateCallback stateCallback;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback doneCallback;

@property (nonatomic) BOOL suspended;

- (void)unsubscribe;

@end
