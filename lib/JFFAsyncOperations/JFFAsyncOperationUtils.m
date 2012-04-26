#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

@interface JFFAsyncOperationOperation : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy   ) JFFSyncOperationWithProgress loadDataBlock;
@property ( nonatomic, retain ) JFFBlockOperation* operation;
@property ( nonatomic, retain ) NSString* queueName;

@end

@implementation JFFAsyncOperationOperation

@synthesize operation     = _operation;
@synthesize loadDataBlock = _loadDataBlock;
@synthesize queueName     = _queueName;

-(void)dealloc
{
    [ _operation     release ];
    [ _loadDataBlock release ];
    [ _queueName     release ];

    [ super dealloc ];
}

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    self.operation = [ JFFBlockOperation performOperationWithQueueName: self.queueName
                                                         loadDataBlock: self.loadDataBlock
                                                      didLoadDataBlock: handler_
                                                         progressBlock: progress_ ];
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

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAmdQueue( JFFSyncOperationWithProgress progressLoadDataBlock_
                                                                                  , NSString* queueName_ )
{
    JFFAsyncOperationOperation* asyncObj_ = [ [ JFFAsyncOperationOperation new ] autorelease ];
    asyncObj_.loadDataBlock = progressLoadDataBlock_;
    asyncObj_.queueName     = queueName_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ )
{
    loadDataBlock_ = [ [ loadDataBlock_ copy ] autorelease ];
    JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                              , JFFAsyncOperationProgressHandler progressCallback_ )
    {
        //JTODO test
        id result_ = loadDataBlock_( error_ );
        if ( result_ && progressCallback_ )
            progressCallback_( result_ );
        return result_;
    };

    return asyncOperationWithSyncOperationWithProgressBlockAmdQueue( progressLoadDataBlock_
                                                                    , queueName_ );
}

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ )
{
    return asyncOperationWithSyncOperationAndQueue( loadDataBlock_, nil );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ )
{
    return asyncOperationWithSyncOperationWithProgressBlockAmdQueue( progressLoadDataBlock_
                                                                    , nil );
}
