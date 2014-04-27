#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JFFCancelAsyncOperationManagerType)
{
    JFFDoNotCancelAsyncOperationManager,
    JFFCancelAsyncOperationManagerWithNoFlag,
    JFFCancelAsyncOperationManagerWithYesFlag
};

@interface JFFAsyncOperationManager : NSObject

@property (nonatomic) BOOL finishAtLoading;
@property (nonatomic) BOOL failAtLoading;
@property (nonatomic) JFFCancelAsyncOperationManagerType cancelAtLoading;

@property (nonatomic, copy, readonly) JFFAsyncOperation loader;
@property (nonatomic, copy, readonly) JFFDidFinishAsyncOperationCallback loaderFinishBlock;
@property (nonatomic, copy, readonly) JFFAsyncOperationHandler loaderHandlerBlock;

@property (nonatomic, readonly) NSUInteger loadingCount;
@property (nonatomic, readonly) BOOL finished;
@property (nonatomic, readonly) BOOL canceled;
@property (nonatomic, readonly) JFFAsyncOperationHandlerTask lastHandleFlag;

- (void)clear;

@end
