#import "JFFBlockOperation.h"

#include <dispatch/dispatch.h>

@interface JFFBlockOperation ()

@property ( nonatomic, copy ) JFFSyncOperationWithProgress loadDataBlock;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didLoadDataBlock;
@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler progressBlock;
@property BOOL finishedOrCanceled;

@end

@implementation JFFBlockOperation
{
    dispatch_queue_t _currentQueue;
    BOOL _barrier;
}

-(void)dealloc
{
    NSAssert( !self->_didLoadDataBlock, @"should be nil" );
    NSAssert( !self->_progressBlock   , @"should be nil" );
    NSAssert( !self->_loadDataBlock   , @"should be nil" );

    dispatch_release( self->_currentQueue );
    self->_currentQueue = NULL;
}

-(id)initWithLoadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
          didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
             progressBlock:( JFFAsyncOperationProgressHandler )progressBlock_
              currentQueue:( dispatch_queue_t )currentQueue_
                   barrier:( BOOL )barrier_
{
    self = [ super init ];

    if ( self )
    {
        self.loadDataBlock    = loadDataBlock_;
        self.didLoadDataBlock = didLoadDataBlock_;
        self.progressBlock    = progressBlock_;

        self->_currentQueue = currentQueue_;
        dispatch_retain( self->_currentQueue );

        self->_barrier = barrier_;
    }

    return self;
}

-(void)finalizeOperations
{
    self->_finishedOrCanceled = YES;

    self->_loadDataBlock    = nil;
    self->_didLoadDataBlock = nil;
    self->_progressBlock    = nil;
}

-(void)didFinishOperationWithResult:( id )result_
                              error:( NSError* )error_
{
    if ( self.finishedOrCanceled )
        return;

    self.didLoadDataBlock( result_, error_ );

    [ self finalizeOperations ];
}

-(void)progressWithInfo:( id )info_
{
    if ( self.progressBlock )
        self.progressBlock( info_ );
}

-(void)cancel
{
    if ( self.finishedOrCanceled )
        return;

    dispatch_queue_t currentQueue_ = dispatch_get_current_queue();
    NSAssert( currentQueue_ == self->_currentQueue, @"Invalid current queue queue" );

    [ self finalizeOperations ];
}

-(void)performBackgroundOperationInQueue:( dispatch_queue_t )queue_
                           loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
{
    void (*dispatch_async_method_)( dispatch_queue_t, dispatch_block_t ) = self->_barrier
        ? &dispatch_barrier_async
        : &dispatch_async;

    dispatch_async_method_( queue_, ^
    {
        if ( self.finishedOrCanceled )
            return;

        NSError* error_ = nil;
        id opResult_    = nil;
        @try
        {
            JFFAsyncOperationProgressHandler progressCallback_ = ^( id info_ )
            {
                dispatch_async( self->_currentQueue, ^
                {
                    [ self progressWithInfo: info_ ];
                } );
            };
            @autoreleasepool
            {
                opResult_ = loadDataBlock_( &error_, progressCallback_ );
            }
        }
        @catch ( NSException* ex_ )
        {
            NSLog( @"critical error: %@", ex_ );
            opResult_ = nil;
            NSString* description_ = [ [ NSString alloc ] initWithFormat: @"exception: %@, reason: %@"
                                      , ex_.name
                                      , ex_.reason ];
            error_ = [ JFFError newErrorWithDescription: description_ ];
        }

        dispatch_async( self->_currentQueue, ^
        {
            [ self didFinishOperationWithResult: opResult_ error: error_ ];
        } );
    } );
}

+(id)performOperationWithQueueName:( const char* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
                     progressBlock:( JFFAsyncOperationProgressHandler )progressBlock_
                           barrier:( BOOL )barrier_
{
    NSParameterAssert( loadDataBlock_    );
    NSParameterAssert( didLoadDataBlock_ );

    dispatch_queue_t currentQueue_ = dispatch_get_current_queue();

    dispatch_queue_t queue_ = NULL;
    if ( queueName_ != NULL && strlen( queueName_ ) != 0 )
    {
        queue_ = dispatch_queue_get_or_create( queueName_
                                              , DISPATCH_QUEUE_CONCURRENT );
    }
    else
    {
        queue_ = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    }

    NSAssert( currentQueue_ != queue_, @"Invalid run queue" );

    JFFBlockOperation* result_ = [ [ self alloc ] initWithLoadDataBlock: loadDataBlock_
                                                       didLoadDataBlock: didLoadDataBlock_
                                                          progressBlock: progressBlock_
                                                           currentQueue: currentQueue_
                                                                barrier: barrier_ ];

    [ result_ performBackgroundOperationInQueue: queue_
                                  loadDataBlock: loadDataBlock_ ];

    return result_;
}

+(id)performOperationWithQueueName:( const char* )queueName_
                     loadDataBlock:( JFFSyncOperationWithProgress )loadDataBlock_
                  didLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didLoadDataBlock_
{
    return [ self performOperationWithQueueName: queueName_
                                  loadDataBlock: loadDataBlock_
                               didLoadDataBlock: didLoadDataBlock_
                                  progressBlock: nil
                                        barrier: NO ];
}

@end
