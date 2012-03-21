#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

@interface JFFAsyncOperationOperation : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy ) JFFSyncOperationWithProgress loadDataBlock;

@end

@implementation JFFAsyncOperationOperation
{
    JFFBlockOperation* _operation;
}

@synthesize loadDataBlock = _loadDataBlock;

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    _operation = [ JFFBlockOperation performOperationWithLoadDataBlock: self.loadDataBlock
                                                      didLoadDataBlock: handler_
                                                         progressBlock: progress_ ];
}

-(void)cancel:( BOOL )canceled_
{
    if ( canceled_ )
        [ _operation cancel ];
}

@end

JFFAsyncOperation asyncOperationWithSyncOperation( JFFSyncOperation loadDataBlock_ )
{
    loadDataBlock_ = [ [ loadDataBlock_ copy ] autorelease ];
    JFFSyncOperationWithProgress progressLoadDataBlock_ = ^id( NSError** error_
                                                              , JFFAsyncOperationProgressHandler progressCallback_ )
    {
        id result_ = loadDataBlock_( error_ );
        if ( result_ && progressCallback_ )
            progressCallback_( result_ );
        return result_;
    };

    return asyncOperationWithSyncOperationWithProgressBlock( progressLoadDataBlock_ );
}

JFFAsyncOperation asyncOperationWithSyncOperationWithProgressBlock( JFFSyncOperationWithProgress progressLoadDataBlock_ )
{
    JFFAsyncOperationOperation* asyncObj_ = [ JFFAsyncOperationOperation new ];
    asyncObj_.loadDataBlock = progressLoadDataBlock_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}
