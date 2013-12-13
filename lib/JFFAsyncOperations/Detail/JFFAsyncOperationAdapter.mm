#import "JFFAsyncOperationAdapter.h"

#import "JFFBlockOperation.h"

@implementation JFFAsyncOperationAdapter

- (instancetype)init
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
    
    _queueAttributes = DISPATCH_QUEUE_CONCURRENT;
    
    return self;
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    self.operation = [JFFBlockOperation performOperationWithQueueName:_queueName.c_str()
                                                        loadDataBlock:_loadDataBlock
                                                     didLoadDataBlock:finishCallback
                                                        progressBlock:progressCallback
                                                              barrier:_barrier
                                                         currentQueue:_currentQueue
                                                   serialOrConcurrent:_queueAttributes];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    if (task == JFFAsyncOperationHandlerTaskCancel) {
        [_operation cancel];
        _operation = nil;
    }
}

@end
