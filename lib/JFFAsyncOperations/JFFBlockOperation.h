#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFBlockOperation : NSObject

+ (instancetype)performOperationWithQueueName:(const char*)queueName
                                loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                             didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
                                progressBlock:(JFFAsyncOperationProgressHandler)progressBlock
                                      barrier:(BOOL)barrier
                                 currentQueue:(dispatch_queue_t)currentQueue
                           serialOrConcurrent:(dispatch_queue_attr_t)serialOrConcurrent;

+ (instancetype)performOperationWithQueueName:(const char*)queueName
                                loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                             didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock;

- (void)cancel;

@end
