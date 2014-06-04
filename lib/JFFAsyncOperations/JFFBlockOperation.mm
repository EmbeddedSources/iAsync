#import "JFFBlockOperation.h"

#include <dispatch/dispatch.h>

@interface JFFBlockOperation ()

@property (nonatomic, copy) JFFSyncOperationWithProgress       loadDataBlock;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback didLoadDataBlock;
@property (nonatomic, copy) JFFAsyncOperationProgressCallback  progressBlock;
@property BOOL finishedOrCanceled;

@end

@implementation JFFBlockOperation
{
    dispatch_queue_t _currentQueue;
    BOOL _barrier;
}

- (void)dealloc
{
    NSAssert(!_didLoadDataBlock, @"should be nil");
    NSAssert(!_progressBlock   , @"should be nil");
    NSAssert(!_loadDataBlock   , @"should be nil");
}

- (instancetype)initWithLoadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                     didLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didLoadDataBlock
                        progressBlock:(JFFAsyncOperationProgressCallback)progressBlock
                         currentQueue:(dispatch_queue_t)currentQueue
                              barrier:(BOOL)barrier
                   serialOrConcurrent:(dispatch_queue_attr_t)serialOrConcurrent
{
    self = [super init];
    
    if (self) {
        _loadDataBlock    = [loadDataBlock    copy];
        _didLoadDataBlock = [didLoadDataBlock copy];
        _progressBlock    = [progressBlock    copy];
        
        _currentQueue = currentQueue;
        _barrier      = barrier;
    }
    
    return self;
}

- (void)finalizeOperations
{
    _finishedOrCanceled = YES;

    _loadDataBlock    = nil;
    _didLoadDataBlock = nil;
    _progressBlock    = nil;
}

- (void)didFinishOperationWithResult:(id)result
                               error:(NSError *)error
{
    if (self.finishedOrCanceled)
        return;
    
    _didLoadDataBlock(result, error);
    
    [self finalizeOperations];
}

- (void)progressWithInfo:(id)info
{
    if (_progressBlock)
        _progressBlock(info);
}

- (void)cancel
{
    if (self.finishedOrCanceled)
        return;
    
    [self finalizeOperations];
}

- (void)performBackgroundOperationInQueue:(dispatch_queue_t)queue
                            loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
{
    void (*dispatchAsyncMethod)(dispatch_queue_t, dispatch_block_t) = _barrier
    ?&dispatch_barrier_async
    :&dispatch_async;
    
    dispatchAsyncMethod(queue, ^{
        if (self.finishedOrCanceled)
            return;
        
        NSError *error;
        id opResult;
        @try {
            JFFAsyncOperationProgressCallback progressCallback = ^(id info) {
                //TODO to garante that finish will called after progress
                dispatch_async(_currentQueue, ^ {
                    [self progressWithInfo:info];
                });
            };
            @autoreleasepool {
                
                opResult = loadDataBlock(&error, progressCallback);
                
                if (!((opResult != nil) ^ (error != nil))) {
                    NSAssert1(NO, @"result xor error should be loaded for queue: %s", dispatch_queue_get_label(queue));
                }
            }
        }
        @catch (NSException *ex) {
            NSLog(@"critical error: %@", ex);
            opResult = nil;
            NSString *description = [[NSString alloc] initWithFormat:@"exception: %@, reason: %@",
                                     ex.name,
                                     ex.reason];
            error = [JFFError newErrorWithDescription:description];
        }
        
        dispatch_async(_currentQueue, ^ {
            [self didFinishOperationWithResult:opResult error:error];
        });
    });
}

+ (instancetype)performOperationWithQueueName:(const char*)queueName
                                loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                             didLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didLoadDataBlock
                                progressBlock:(JFFAsyncOperationProgressCallback)progressBlock
                                      barrier:(BOOL)barrier
                                 currentQueue:(dispatch_queue_t)currentQueue
                           serialOrConcurrent:(dispatch_queue_attr_t)serialOrConcurrent
{
    NSParameterAssert(loadDataBlock   );
    NSParameterAssert(didLoadDataBlock);
    NSParameterAssert(currentQueue    );
    
    dispatch_queue_t queue = NULL;
    if (queueName != NULL && strlen(queueName) != 0) {
        queue = dispatch_queue_get_or_create(queueName, serialOrConcurrent);
    } else {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    NSAssert(currentQueue != queue, @"Invalid run queue");
    
    JFFBlockOperation *result = [[self alloc] initWithLoadDataBlock:loadDataBlock
                                                   didLoadDataBlock:didLoadDataBlock
                                                      progressBlock:progressBlock
                                                       currentQueue:currentQueue
                                                            barrier:barrier
                                                 serialOrConcurrent:serialOrConcurrent];
    
    [result performBackgroundOperationInQueue:queue
                                loadDataBlock:loadDataBlock];
    
    return result;
}

+ (instancetype)performOperationWithQueueName:(const char *)queueName
                                loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                             didLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didLoadDataBlock
{
    NSParameterAssert([NSThread isMainThread]);
    return [self performOperationWithQueueName:queueName
                                 loadDataBlock:loadDataBlock
                              didLoadDataBlock:didLoadDataBlock
                                 progressBlock:nil
                                       barrier:NO
                                  currentQueue:dispatch_get_main_queue()
                            serialOrConcurrent:DISPATCH_QUEUE_CONCURRENT];
}

@end
