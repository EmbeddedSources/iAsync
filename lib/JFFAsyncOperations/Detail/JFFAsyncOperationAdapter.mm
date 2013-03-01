#import "JFFAsyncOperationAdapter.h"

#import "JFFBlockOperation.h"

@implementation JFFAsyncOperationAdapter

-(id)init
{
    self = [ super init ];
    if ( nil == self )
    {
        return nil;
    }

    self->_queueAttributes = DISPATCH_QUEUE_CONCURRENT;

    return self;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    self.operation = [JFFBlockOperation performOperationWithQueueName:self.queueName.c_str()
                                                        loadDataBlock:self.loadDataBlock
                                                     didLoadDataBlock:handler
                                                        progressBlock:progress
                                                              barrier:self.barrier
                                                   serialOrConcurrent:self->_queueAttributes];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled) {
        [self.operation cancel];
        self.operation = nil;
    }
}

@end
