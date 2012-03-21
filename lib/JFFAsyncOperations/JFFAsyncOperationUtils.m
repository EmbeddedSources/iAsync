#import "JFFAsyncOperationUtils.h"

#import "JFFBlockOperation.h"
#import "JFFAsyncOperationBuilder.h"

@interface JFFAsyncOperationOperation : NSObject < JFFAsyncOperationInterface >

@property ( nonatomic, copy ) JFFSyncOperationWithProgress loadDataBlock;
@property ( nonatomic, retain ) JFFBlockOperation* operation;

@end

@implementation JFFAsyncOperationOperation

@synthesize operation     = _operation;
@synthesize loadDataBlock = _loadDataBlock;

-(void)dealloc
{
    [ _operation release ];
    [ _loadDataBlock release ];

    [ super dealloc ];
}

-(void)asyncOperationWithResultHandler:( void (^)( id, NSError* ) )handler_
                       progressHandler:( void (^)( id ) )progress_
{
    self.operation = [ JFFBlockOperation performOperationWithLoadDataBlock: self.loadDataBlock
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
    JFFAsyncOperationOperation* asyncObj_ = [ [ JFFAsyncOperationOperation new ] autorelease ];
    asyncObj_.loadDataBlock = progressLoadDataBlock_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}
