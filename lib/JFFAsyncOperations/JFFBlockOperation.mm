#import "JFFBlockOperation.h"

#include <dispatch/dispatch.h>

@interface JFFBlockOperation ()

@property (nonatomic, copy) JFFSyncOperationWithProgress      loadDataBlock;
@property (nonatomic, copy) JFFDidFinishAsyncOperationHandler didLoadDataBlock;
@property (nonatomic, copy) JFFAsyncOperationProgressHandler  progressBlock;
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
    
    dispatch_release(_currentQueue);
    _currentQueue = NULL;
}

- (id)initWithLoadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
           didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
              progressBlock:(JFFAsyncOperationProgressHandler)progressBlock
               currentQueue:(dispatch_queue_t)currentQueue
                    barrier:(BOOL)barrier
         serialOrConcurrent:( dispatch_queue_attr_t )serialOrConcurrent
{
    self = [super init];
    
    if (self) {
        self.loadDataBlock    = loadDataBlock;
        self.didLoadDataBlock = didLoadDataBlock;
        self.progressBlock    = progressBlock;
        
        _currentQueue = currentQueue;
        dispatch_retain(_currentQueue);
        
        _barrier = barrier;
    }
    
    return self;
}

-(void)finalizeOperations
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
    
    self.didLoadDataBlock(result, error);
    
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
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    NSAssert(currentQueue == _currentQueue, @"Invalid current queue queue");
    
    [self finalizeOperations];
}

- (void)performBackgroundOperationInQueue:(dispatch_queue_t)queue
                            loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
{
    void (*dispatchAsyncMethod)(dispatch_queue_t, dispatch_block_t) = _barrier
    ?&dispatch_barrier_async
    :&dispatch_async;
    
//    static int val;
//    NSLog(@"dispatchAsyncMethod+: %d", ++val);
    dispatchAsyncMethod(queue, ^{
        if (self.finishedOrCanceled)
            return;
        
        NSError *error;
        id opResult;
        @try {
            JFFAsyncOperationProgressHandler progressCallback = ^(id info) {
                //TODO to garante that finish will called after progress
                dispatch_async(_currentQueue, ^ {
                    [self progressWithInfo:info];
                });
            };
            @autoreleasepool {
                opResult = loadDataBlock(&error, progressCallback);
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
//            NSLog(@"dispatchAsyncMethod+: %d", --val);
            [self didFinishOperationWithResult:opResult error:error];
        });
    });
}

+ (id)performOperationWithQueueName:(const char*)queueName
                      loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                   didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
                      progressBlock:(JFFAsyncOperationProgressHandler)progressBlock
                            barrier:(BOOL)barrier
                 serialOrConcurrent:(dispatch_queue_attr_t)serialOrConcurrent
{
    NSParameterAssert(loadDataBlock   );
    NSParameterAssert(didLoadDataBlock);
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    
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

+ (id)performOperationWithQueueName:(const char *)queueName
                      loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
                   didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
{
    return [self performOperationWithQueueName:queueName
                                 loadDataBlock:loadDataBlock
                              didLoadDataBlock:didLoadDataBlock
                                 progressBlock:nil
                                       barrier:NO
                            serialOrConcurrent:DISPATCH_QUEUE_CONCURRENT];
}

@end
