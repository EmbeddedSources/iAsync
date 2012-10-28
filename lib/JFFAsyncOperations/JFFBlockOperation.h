#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFBlockOperation : NSObject

+ (id)performOperationWithQueueName:(const char*)queueName
                      loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                   didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
                      progressBlock:(JFFAsyncOperationProgressHandler)progressBlock
                            barrier:(BOOL)barrier;

+ (id)performOperationWithQueueName:(const char*)queueName
                      loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                   didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock;

- (void)cancel;

@end
