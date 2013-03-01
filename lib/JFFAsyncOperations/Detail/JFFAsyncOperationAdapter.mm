#import "JFFAsyncOperationAdapter.h"

#import "JFFBlockOperation.h"

@implementation JFFAsyncOperationAdapter

- (id)init
{
    self = [super init];
    if (nil == self) {
        return nil;
    }
    
    _queueAttributes = DISPATCH_QUEUE_CONCURRENT;
    
    return self;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    self.operation = [JFFBlockOperation performOperationWithQueueName:_queueName.c_str()
                                                        loadDataBlock:_loadDataBlock
                                                     didLoadDataBlock:handler
                                                        progressBlock:progress
                                                              barrier:_barrier
                                                   serialOrConcurrent:_queueAttributes];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled) {
        [_operation cancel];
        _operation = nil;
    }
}

@end
