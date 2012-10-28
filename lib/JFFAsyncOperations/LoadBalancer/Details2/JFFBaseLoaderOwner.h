#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFLimitedLoadersQueue;

@interface JFFBaseLoaderOwner : NSObject

@property (nonatomic, copy) JFFAsyncOperation loader;
@property (nonatomic, weak) JFFLimitedLoadersQueue *queue;

@property (nonatomic, copy) JFFCancelAsyncOperation cancelLoader;
@property (nonatomic, copy) JFFAsyncOperationProgressHandler progressCallback;
@property (nonatomic, copy) JFFCancelAsyncOperationHandler cancelCallback;
@property (nonatomic, copy) JFFDidFinishAsyncOperationHandler doneCallback;

+ (id)newLoaderOwnerWithLoader:(JFFAsyncOperation)loader
                         queue:(JFFLimitedLoadersQueue *)queue;

- (void)performLoader;

@end
