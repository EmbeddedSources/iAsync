#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

@interface JFFAsyncOperationOperation : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy   ) JFFSyncOperationWithProgress loadDataBlock;
@property ( nonatomic, retain ) JFFBlockOperation* operation;
@property ( nonatomic, retain ) NSString* queueName;
@property ( nonatomic, assign ) BOOL concurrent;

@end

@implementation JFFAsyncOperationOperation

@synthesize operation     = _operation;
@synthesize loadDataBlock = _loadDataBlock;
@synthesize queueName     = _queueName;
@synthesize concurrent    = _concurrent;

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

static JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlockAmdQueue( JFFSyncOperationWithProgress progressLoadDataBlock_
                                                                                  , NSString* queueName_
                                                                                  , BOOL concurent_ )
{
    JFFAsyncOperationOperation* asyncObj_ = [ JFFAsyncOperationOperation new ];
    asyncObj_.loadDataBlock = progressLoadDataBlock_;
    asyncObj_.queueName     = queueName_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

static JFFAsyncOperation privateAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_
                                                                        , NSString* queueName_
                                                                        , BOOL concurrent_ )
{
    loadDataBlock_ = [ loadDataBlock_ copy ];
    JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                              , JFFAsyncOperationProgressHandler progressCallback_ )
    {
        //JTODO test this if
        id result_ = loadDataBlock_( error_ );
        if ( result_ && progressCallback_ )
            progressCallback_( result_ );
        return result_;
    };

    return asyncOperationWithSyncOperationWithProgressBlockAmdQueue( progressLoadDataBlock_
                                                                    , queueName_
                                                                    , concurrent_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , YES );
}

JFFAsyncOperation serialAsyncOperationWithSyncOperationAndQueue( JFFSyncOperation loadDataBlock_, NSString* queueName_ )
{
    return privateAsyncOperationWithSyncOperationAndQueue( loadDataBlock_
                                                          , queueName_
                                                          , NO );
}

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ )
{
    return asyncOperationWithSyncOperationAndQueue( loadDataBlock_, nil );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ )
{
    return asyncOperationWithSyncOperationWithProgressBlockAmdQueue( progressLoadDataBlock_
                                                                    , nil
                                                                    , YES );
}
