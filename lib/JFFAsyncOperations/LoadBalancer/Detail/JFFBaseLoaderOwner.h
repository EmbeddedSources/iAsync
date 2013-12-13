#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFLimitedLoadersQueue;

@interface JFFBaseLoaderOwner : NSObject

@property (nonatomic) BOOL barrier;

@property (nonatomic, copy) JFFAsyncOperation loader;
@property (nonatomic, weak) JFFLimitedLoadersQueue *queue;

@property (nonatomic, copy) JFFAsyncOperationHandler loadersHandler;
@property (nonatomic, copy) JFFAsyncOperationProgressCallback progressCallback;
@property (nonatomic, copy) JFFAsyncOperationChangeStateCallback stateCallback;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback doneCallback;

+ (instancetype)newLoaderOwnerWithLoader:(JFFAsyncOperation)loader
                                   queue:(JFFLimitedLoadersQueue *)queue;

- (void)performLoader;

@end
