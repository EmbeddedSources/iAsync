#import "JFFAsyncOperationAdapter.h"

#import "JFFBlockOperation.h"

@implementation JFFAsyncOperationAdapter

@synthesize operation     = _operation;
@synthesize loadDataBlock = _loadDataBlock;
@synthesize queueName     = _queueName;
@synthesize barrier       = _barrier;

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    self.operation = [ JFFBlockOperation performOperationWithQueueName: self.queueName.c_str()
                                                         loadDataBlock: self.loadDataBlock
                                                      didLoadDataBlock: handler_
                                                         progressBlock: progress_
                                                               barrier: self.barrier ];
}

-(void)cancel:( BOOL )canceled_
{
    if ( canceled_ )
    {
        [ self.operation cancel ];
        self.operation = nil;
    }
}

@end
