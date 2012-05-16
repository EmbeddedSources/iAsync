#import "JFFAsyncOperationOperation.h"

#import "JFFBlockOperation.h"

@implementation JFFAsyncOperationOperation

@synthesize operation     = _operation;
@synthesize loadDataBlock = _loadDataBlock;
@synthesize queueName     = _queueName;
@synthesize concurrent    = _concurrent;

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    self.operation = [ JFFBlockOperation performOperationWithQueueName: self.queueName
                                                         loadDataBlock: self.loadDataBlock
                                                      didLoadDataBlock: handler_
                                                         progressBlock: progress_
                                                            concurrent: self.concurrent ];
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
