#import "JFFAsyncOperationAdapter.h"

#import "JFFBlockOperation.h"

@implementation JFFAsyncOperationAdapter

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    self.operation = [JFFBlockOperation performOperationWithQueueName:self.queueName.c_str()
                                                        loadDataBlock:self.loadDataBlock
                                                     didLoadDataBlock:handler
                                                        progressBlock:progress
                                                              barrier:self.barrier];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled) {
        [self.operation cancel];
        self.operation = nil;
    }
}

@end
