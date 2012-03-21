#import "JFFBlockOperation.h"

#include <dispatch/dispatch.h>

@interface JFFBlockOperation ()

@property ( nonatomic, copy ) JFFSyncOperation loadDataBlock;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didLoadDataBlock;
@property ( assign ) BOOL finishedOrCanceled;

@end

@implementation JFFBlockOperation
{
    dispatch_queue_t _currentQueue;
}

@synthesize loadDataBlock      = _loadDataBlock;
@synthesize didLoadDataBlock   = _didLoadDataBlock;
@synthesize finishedOrCanceled = _finishedOrCanceled;

-(void)dealloc
{
    NSAssert( !_didLoadDataBlock, @"should be nil" );
    NSAssert( !_loadDataBlock, @"should be nil" );
    NSAssert( !_currentQueue, @"should be nil" );
}

-(id)initWithLoadDataBlock:( JFFSyncOperation )loadDataBlock_
          didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
              currentQueue:( dispatch_queue_t )currentQueue_
{
    self = [ super init ];

    if ( self )
    {
        self.loadDataBlock    = loadDataBlock_;
        self.didLoadDataBlock = didLoadDataBlock_;

        _currentQueue = currentQueue_;
        dispatch_retain( _currentQueue );
    }

    return self;
}

-(void)finalizeOperations
{
    self.finishedOrCanceled = YES;

    self.loadDataBlock    = nil;
    self.didLoadDataBlock = nil;
    dispatch_release( _currentQueue );
    _currentQueue = NULL;
}

-(void)didFinishOperationWithResult:( id )result_
                              error:( NSError* )error_
{
    if ( self.finishedOrCanceled )
        return;

    self.didLoadDataBlock( result_, error_ );

    [ self finalizeOperations ];
}

-(void)cancel
{
    if ( self.finishedOrCanceled )
        return;

    dispatch_queue_t currentQueue_ = dispatch_get_current_queue();
    NSAssert( currentQueue_ == _currentQueue, @"Invalid current queue queue" );

    [ self finalizeOperations ];
}

-(void)performBackgroundOperationInQueue:( dispatch_queue_t )queue_
                           loadDataBlock:( JFFSyncOperation )loadDataBlock_
{
    dispatch_async( queue_, ^
    {
        if ( self.finishedOrCanceled )
            return;

        NSError* error_ = nil;
        id opResult_    = nil;
        @try
        {
            opResult_ = loadDataBlock_( &error_ );
        }
        @catch ( NSException* ex_ )
        {
            NSLog( @"critical error: %@", ex_ );
            opResult_ = nil;
            NSString* description_ = [ NSString stringWithFormat: @"exception: %@, reason: %@"
                                      , ex_.name
                                      , ex_.reason ];
            error_ = [ JFFError errorWithDescription: description_ ];
        }

        dispatch_async( _currentQueue, ^
        {
            [ self didFinishOperationWithResult: opResult_ error: error_ ];
        } );
    } );
}

+(id)performOperationWithLoadDataBlock:( JFFSyncOperation )loadDataBlock_
                      didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
{
    NSParameterAssert( loadDataBlock_ );
    NSParameterAssert( didLoadDataBlock_ );

    dispatch_queue_t currentQueue_ = dispatch_get_current_queue();
    dispatch_queue_t queue_        = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    NSAssert( currentQueue_ != queue_, @"Invalid run queue" );

    JFFBlockOperation* result_ = [ [ self alloc ] initWithLoadDataBlock: loadDataBlock_
                                                       didLoadDataBlock: didLoadDataBlock_
                                                           currentQueue: currentQueue_ ];

    [ result_ performBackgroundOperationInQueue: queue_
                                  loadDataBlock: loadDataBlock_ ];

    return result_;
}

@end
