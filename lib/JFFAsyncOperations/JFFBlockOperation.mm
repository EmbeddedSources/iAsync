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
    NSAssert(!self->_didLoadDataBlock, @"should be nil");
    NSAssert(!self->_progressBlock   , @"should be nil");
    NSAssert(!self->_loadDataBlock   , @"should be nil");
    
    dispatch_release(self->_currentQueue);
    self->_currentQueue = NULL;
}

- (id)initWithLoadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
           didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock
              progressBlock:(JFFAsyncOperationProgressHandler)progressBlock
               currentQueue:(dispatch_queue_t )currentQueue
                    barrier:(BOOL)barrier
{
    self = [ super init ];
    
    if ( self )
    {
        self.loadDataBlock    = loadDataBlock;
        self.didLoadDataBlock = didLoadDataBlock;
        self.progressBlock    = progressBlock;
        
        self->_currentQueue = currentQueue;
        dispatch_retain(self->_currentQueue);
        
        self->_barrier = barrier;
    }
    
    return self;
}

-(void)finalizeOperations
{
    self->_finishedOrCanceled = YES;

    self->_loadDataBlock    = nil;
    self->_didLoadDataBlock = nil;
    self->_progressBlock    = nil;
}

- (void)didFinishOperationWithResult:(id)result
                               error:(NSError *)error
{
    if ( self.finishedOrCanceled )
        return;
    
    self.didLoadDataBlock(result, error);
    
    [ self finalizeOperations ];
}

- (void)progressWithInfo:(id)info
{
    if (self->_progressBlock)
        self->_progressBlock(info);
}

- (void)cancel
{
    if (self.finishedOrCanceled)
        return;
    
    dispatch_queue_t currentQueue = dispatch_get_current_queue();
    NSAssert(currentQueue == self->_currentQueue, @"Invalid current queue queue");
    
    [self finalizeOperations];
}

- (void)performBackgroundOperationInQueue:(dispatch_queue_t)queue
                            loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock
{
    void (*dispatch_async_method)( dispatch_queue_t, dispatch_block_t ) = self->_barrier
    ? &dispatch_barrier_async
    : &dispatch_async;
    
    dispatch_async_method(queue, ^
    {
        if ( self.finishedOrCanceled )
            return;
        
        NSError *error;
        id opResult;
        @try {
            JFFAsyncOperationProgressHandler progressCallback = ^(id info) {
                dispatch_async(self->_currentQueue, ^ {
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
        
        dispatch_async( self->_currentQueue, ^ {
            [self didFinishOperationWithResult:opResult error:error];
        });
    });
}

+ (id)performOperationWithQueueName:(const char*)queueName
                      loadDataBlock:(JFFSyncOperationWithProgress)loadDataBlock_
                   didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock_
                      progressBlock:(JFFAsyncOperationProgressHandler)progressBlock_
                            barrier:(BOOL )barrier_
{
    NSParameterAssert(loadDataBlock_   );
    NSParameterAssert(didLoadDataBlock_);
    
    dispatch_queue_t currentQueue_ = dispatch_get_current_queue();
    
    dispatch_queue_t queue_ = NULL;
    if (queueName != NULL && strlen(queueName) != 0) {
        queue_ = dispatch_queue_get_or_create( queueName
                                              , DISPATCH_QUEUE_CONCURRENT );
    } else {
        queue_ = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    }
    
    NSAssert( currentQueue_ != queue_, @"Invalid run queue" );
    
    JFFBlockOperation* result_ = [ [ self alloc ] initWithLoadDataBlock: loadDataBlock_
                                                       didLoadDataBlock: didLoadDataBlock_
                                                          progressBlock: progressBlock_
                                                           currentQueue: currentQueue_
                                                                barrier: barrier_ ];

    [ result_ performBackgroundOperationInQueue: queue_
                                  loadDataBlock: loadDataBlock_ ];

    return result_;
}

+(id)performOperationWithQueueName:( const char* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
{
    return [ self performOperationWithQueueName: queueName_
                                  loadDataBlock: loadDataBlock_
                               didLoadDataBlock: didLoadDataBlock_
                                  progressBlock: nil
                                        barrier: NO ];
}

@end
