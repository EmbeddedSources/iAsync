#import <JFFUtils/Blocks/JFFSimpleBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFAsyncOperationProgressBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>

@interface WeakAsyncOperationTest : GHTestCase
@end

@implementation WeakAsyncOperationTest

-(void)setUp
{
    [ JFFSimpleBlockHolder                  enableInstancesCounting ];
    [ JFFCancelAsyncOperationBlockHolder    enableInstancesCounting ];
    [ JFFAsyncOperationProgressBlockHolder  enableInstancesCounting ];
    [ JFFDidFinishAsyncOperationBlockHolder enableInstancesCounting ];
}

-(void)testCancelActionAfterUnsubscribeOnDealloc
{
    @autoreleasepool
    {
        NSObject* obj_ = [ NSObject new ];

        __block BOOL cancel_callback_called_ = NO;

        JFFCancelAsyncOperation cancel_ = nil;

        @autoreleasepool
        {
            JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                    , JFFCancelAsyncOperationHandler cancel_callback_
                                                                    , JFFDidFinishAsyncOperationHandler done_callback_ )
            {
                cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
                return [ [ ^void( BOOL cancel_ )
                {
                    if ( cancel_callback_ )
                        cancel_callback_( cancel_ );
                } copy ] autorelease ];
            };

            operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

            cancel_ = operation_( nil, ^( BOOL canceled_ )
            {
                cancel_callback_called_ = YES;
            }, nil );
            [ cancel_ retain ];
        }

        [ obj_ release ];

        GHAssertTrue( cancel_callback_called_, @"Cancel callback should be called" );
        cancel_callback_called_ = NO;

        cancel_( YES );
        [ cancel_ release ];

        GHAssertFalse( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testOnceCancelBlockCallingOnDealloc
{
    @autoreleasepool
    {
        NSObject* obj_ = [ NSObject new ];

        __block NSUInteger cancel_callback_call_count_ = 0;

        @autoreleasepool
        {
            NSAutoreleasePool* pool_ = [ NSAutoreleasePool new ];

            JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                    , JFFCancelAsyncOperationHandler cancel_callback_
                                                                    , JFFDidFinishAsyncOperationHandler done_callback_ )
            {
                cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
                return [ [ ^void( BOOL cancel_ )
                {
                    ++cancel_callback_call_count_;
                    if ( cancel_callback_ )
                        cancel_callback_( cancel_ );
                } copy ] autorelease ];
            };

            operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

            operation_( nil, nil, nil );

            [ pool_ release ];
        }

        [ obj_ release ];

        GHAssertTrue( 1 == cancel_callback_call_count_, @"Cancel callback should not be called after dealloc" );
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

-(void)testCancelCallbackCallingOnCancelBlock
{
    @autoreleasepool
    {
        NSObject* obj_ = [ NSObject new ];

        __block BOOL cancel_block_called_ = NO;

        JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                , JFFCancelAsyncOperationHandler cancel_callback_
                                                                , JFFDidFinishAsyncOperationHandler done_callback_ )
        {
            cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
            return [ [ ^void( BOOL cancel_ )
            {
                cancel_block_called_ = cancel_;
                if ( cancel_callback_ )
                    cancel_callback_( cancel_ );
            } copy ] autorelease ];
        };

        operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

        __block BOOL cancel_callback_called_ = NO;

        JFFCancelAsyncOperation cancel_ = operation_( nil, ^( BOOL canceled_ )
        {
            cancel_callback_called_ = YES;
        }, nil );

        cancel_( YES );

        GHAssertTrue( cancel_callback_called_, @"Cancel callback should not be called after dealloc" );
        GHAssertTrue( cancel_block_called_, @"Cancel callback should not be called after dealloc" );

        [ obj_ release ];
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

// When unsubscribe from autoCancelAsyncOperation -> native should not be canceled
-(void)testUnsubscribeFromAutoCancel
{
    @autoreleasepool
    {
        NSObject* operation_owner_ = [ NSObject new ];

        __block BOOL native_cancel_block_called_ = NO;

        JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                , JFFCancelAsyncOperationHandler cancel_callback_
                                                                , JFFDidFinishAsyncOperationHandler done_callback_ )
        {
            cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
            return [ [ ^void( BOOL cancel_ )
            {
                native_cancel_block_called_ = YES;
                if ( cancel_callback_ )
                    cancel_callback_( cancel_ );
            } copy ] autorelease ];
        };

        JFFAsyncOperation auto_cancel_operation_ = [ operation_owner_ autoCancelOnDeallocAsyncOperation: operation_ ];

        __block BOOL deallocated_ = NO;

        NSObject* owned_by_callbacks_ = [ NSObject new ];
        [ owned_by_callbacks_ addOnDeallocBlock: ^void( void )
        {
            deallocated_ = YES;
        } ];

        JFFAsyncOperationProgressHandler progress_callback_ = ^void( id progress_info_ )
        {
            //simulate using object in callback block
            [ owned_by_callbacks_ class ];
        };
        __block BOOL cancel_callback_called_ = NO;
        JFFCancelAsyncOperationHandler cancel_callback_ = ^void( BOOL canceled_ )
        {
            cancel_callback_called_ = !canceled_;
            //simulate using object in callback block
            [ owned_by_callbacks_ class ];
        };
        JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
        {
            //simulate using object in callback block
            [ owned_by_callbacks_ class ];
        };

        JFFCancelAsyncOperation cancel_ = auto_cancel_operation_( progress_callback_
                                                                 , cancel_callback_
                                                                 , done_callback_ );

        [ owned_by_callbacks_ release ];

        GHAssertFalse( deallocated_, @"owned_by_callbacks_ object should not be deallocated" );

        cancel_( NO );

        GHAssertTrue( native_cancel_block_called_, @"Native cancel block should not be called" );
        GHAssertTrue( deallocated_, @"owned_by_callbacks_ objet should be deallocated" );
        GHAssertTrue( cancel_callback_called_, @"cancel callback should ba called" );

        [ operation_owner_ release ];
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
}

-(void)testCancelCallbackCallingForNativeLoaderWhenWeekDelegateRemove
{
    @autoreleasepool
    {
        NSObject* operation_owner_ = [ NSObject new ];

        NSObject* delegate_ = [ NSObject new ];
        __block BOOL delegateDeallocated_ = NO;
        [ delegate_ addOnDeallocBlock: ^void( void )
        {
            delegateDeallocated_ = YES;
        } ];

        __block BOOL native_cancel_block_called_ = NO;
        __block BOOL unsibscribe_cancel_block_called_ = NO;

        JFFAsyncOperation operation_ = nil;

        @autoreleasepool
        {
            operation_ = [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                      , JFFCancelAsyncOperationHandler cancel_callback_
                                                      , JFFDidFinishAsyncOperationHandler done_callback_ )
            {
                return [ [ ^void( BOOL cancel_ )
                {
                    if ( cancel_callback_ )
                        cancel_callback_( cancel_ );
                    native_cancel_block_called_ = YES;
                } copy ] autorelease ];
            } copy ] autorelease ];
            [ operation_ retain ];//like native operation still living

            JFFAsyncOperation auto_cancel_operation_ = [ operation_owner_ autoCancelOnDeallocAsyncOperation: operation_ ];

            __block id weak_delegate_ = delegate_;

            JFFCancelAsyncOperationHandler unsubscribe_callback_ = ^( BOOL canceled_ )
            {
                unsibscribe_cancel_block_called_ = !canceled_;
            };
            [ weak_delegate_ autoUnsubsribeOnDeallocAsyncOperation: auto_cancel_operation_ ]( nil
                                                                                             , unsubscribe_callback_
                                                                                             , ^void( id result_
                                                                                                  , NSError* error_ )
            {
                NSLog( @"notify delegate: %@, with owner: %@", weak_delegate_, operation_owner_ );
            } );
        }

        [ delegate_ release ];

        GHAssertTrue( delegateDeallocated_            , @"OK" );
        GHAssertTrue( native_cancel_block_called_     , @"OK" );
        GHAssertTrue( unsibscribe_cancel_block_called_, @"OK" );
        native_cancel_block_called_ = NO;

        [ operation_owner_ release ];

        GHAssertFalse( native_cancel_block_called_, @"operation_ should be canceled here" );

        [ operation_ release ];
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
}

@end
