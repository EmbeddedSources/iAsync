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
    @autoreleasepool {
        __block BOOL cancelCallbackCalled_ = NO;
        JFFCancelAsyncOperation cancel_;
        
        @autoreleasepool
        {
            NSObject* obj_ = [ NSObject new ];

            @autoreleasepool
            {
                JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                                                        , JFFDidFinishAsyncOperationHandler done_callback_ )
                {
                    cancelCallback_ = [ cancelCallback_ copy ];
                    return [ ^void( BOOL cancel_ )
                    {
                        if ( cancelCallback_ )
                            cancelCallback_( cancel_ );
                    } copy ];
                };

                operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

                cancel_ = operation_( nil, ^( BOOL canceled_ )
                {
                    cancelCallbackCalled_ = YES;
                }, nil );
            }
        }

        GHAssertTrue( cancelCallbackCalled_, @"Cancel callback should be called" );
        cancelCallbackCalled_ = NO;

        cancel_( YES );

        GHAssertFalse( cancelCallbackCalled_, @"Cancel callback should not be called after dealloc" );
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
        __block NSUInteger cancelCallbackCallCount_ = 0;

        @autoreleasepool
        {
            NSObject* obj_ = [ NSObject new ];

            JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
            {
                cancelCallback_ = [ cancelCallback_ copy ];
                return [ ^void( BOOL cancel_ )
                {
                    ++cancelCallbackCallCount_;
                    if ( cancelCallback_ )
                        cancelCallback_( cancel_ );
                } copy ];
            };

            operation_ = [ obj_ autoUnsubsribeOnDeallocAsyncOperation: operation_ ];

            operation_( nil, nil, nil );
        }

        GHAssertTrue( 1 == cancelCallbackCallCount_, @"Cancel callback should not be called after dealloc" );
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"All object of this class should be deallocated" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"All object of this class should be deallocated" );
}

- (void)testCancelCallbackCallingOnCancelBlock
{
    @autoreleasepool {
        NSObject *obj = [NSObject new];
        
        __block BOOL cancelBlockCalled = NO;
        
        JFFAsyncOperation operation = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                               JFFCancelAsyncOperationHandler cancelCallback,
                                                               JFFDidFinishAsyncOperationHandler doneCallback) {
            cancelCallback = [cancelCallback copy];
            return [^void(BOOL cancel) {
                cancelBlockCalled = cancel;
                if (cancelCallback)
                    cancelCallback(cancel);
            }copy];
        };
        
        operation = [obj autoUnsubsribeOnDeallocAsyncOperation:operation];
        
        __block BOOL cancelCallbackCalled = NO;
        
        JFFCancelAsyncOperation cancel = operation(nil, ^(BOOL canceled) {
            cancelCallbackCalled = YES;
        }, nil);
        
        cancel(YES);
        
        GHAssertTrue(cancelCallbackCalled, @"Cancel callback should not be called after dealloc");
        GHAssertTrue(cancelBlockCalled, @"Cancel callback should not be called after dealloc");
    }
    
    GHAssertTrue(0 == [JFFSimpleBlockHolder                  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFCancelAsyncOperationBlockHolder    instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFAsyncOperationProgressBlockHolder  instancesCount], @"All object of this class should be deallocated");
    GHAssertTrue(0 == [JFFDidFinishAsyncOperationBlockHolder instancesCount], @"All object of this class should be deallocated");
}

// When unsubscribe from autoCancelAsyncOperation -> native should not be canceled
-(void)testUnsubscribeFromAutoCancel
{
    @autoreleasepool
    {
        NSObject* operationOwner_ = [ NSObject new ];

        __block BOOL nativeCancelBlockCalled_ = NO;

        JFFAsyncOperation operation_ = ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                                                , JFFCancelAsyncOperationHandler cancelCallback_
                                                                , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            cancelCallback_ = [ cancelCallback_ copy ];
            return [ ^void( BOOL cancel_ )
            {
                nativeCancelBlockCalled_ = YES;
                if ( cancelCallback_ )
                    cancelCallback_( cancel_ );
            } copy ];
        };

        JFFAsyncOperation autoCancelOperation_ = [ operationOwner_ autoCancelOnDeallocAsyncOperation: operation_ ];

        __block BOOL deallocated_ = NO;
        JFFCancelAsyncOperation cancel_;
        __block BOOL cancelCallbackCalled_ = NO;

        @autoreleasepool
        {
            NSObject* ownedByCallbacks_ = [ NSObject new ];
            [ ownedByCallbacks_ addOnDeallocBlock: ^void( void )
            {
                deallocated_ = YES;
            } ];

            JFFAsyncOperationProgressHandler progress_callback_ = ^void( id progressInfo_ )
            {
                //simulate using object in callback block
                [ ownedByCallbacks_ class ];
            };
            JFFCancelAsyncOperationHandler cancel_callback_ = ^void( BOOL canceled_ )
            {
                cancelCallbackCalled_ = !canceled_;
                //simulate using object in callback block
                [ ownedByCallbacks_ class ];
            };
            JFFDidFinishAsyncOperationHandler done_callback_ = ^void( id result_, NSError* error_ )
            {
                //simulate using object in callback block
                [ ownedByCallbacks_ class ];
            };

            cancel_ = autoCancelOperation_( progress_callback_
                                           , cancel_callback_
                                           , done_callback_ );
        }

        GHAssertFalse( deallocated_, @"owned_by_callbacks_ object should not be deallocated" );

        cancel_( NO );

        GHAssertTrue( nativeCancelBlockCalled_, @"Native cancel block should not be called" );
        GHAssertTrue( deallocated_, @"owned_by_callbacks_ objet should be deallocated" );
        GHAssertTrue( cancelCallbackCalled_, @"cancel callback should ba called" );
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
        __block BOOL nativeCancelBlockCalled_ = NO;

        @autoreleasepool
        {
            NSObject* operationOwner_ = [ NSObject new ];

            __block BOOL unsibscribeCancelBlockCalled_ = NO;
            __block BOOL delegateDeallocated_ = NO;

            @autoreleasepool
            {
                NSObject* delegate_ = [ NSObject new ];
                [ delegate_ addOnDeallocBlock: ^void( void )
                {
                    delegateDeallocated_ = YES;
                } ];

                JFFAsyncOperation operation_ = nil;

                @autoreleasepool
                {
                    operation_ = [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                                              , JFFCancelAsyncOperationHandler cancelCallback_
                                                              , JFFDidFinishAsyncOperationHandler doneCallback_ )
                    {
                        return [ ^void( BOOL cancel_ )
                        {
                            if ( cancelCallback_ )
                                cancelCallback_( cancel_ );
                            nativeCancelBlockCalled_ = YES;
                        } copy ];
                    } copy ];
                    //like native operation still living

                    JFFAsyncOperation autoCancelOperation_ = [ operationOwner_ autoCancelOnDeallocAsyncOperation: operation_ ];

                    __unsafe_unretained id weakDelegate_ = delegate_;

                    JFFCancelAsyncOperationHandler unsubscribeCallback_ = ^( BOOL canceled_ )
                    {
                        unsibscribeCancelBlockCalled_ = !canceled_;
                    };
                    [ weakDelegate_ autoUnsubsribeOnDeallocAsyncOperation: autoCancelOperation_ ]( nil
                                                                                                     , unsubscribeCallback_
                                                                                                     , ^void( id result_
                                                                                                          , NSError* error_ )
                    {
                        NSLog( @"notify delegate: %@, with owner: %@", weakDelegate_, operationOwner_ );
                    } );
                }
            }

            GHAssertTrue( delegateDeallocated_         , @"OK" );
            GHAssertTrue( nativeCancelBlockCalled_     , @"OK" );
            GHAssertTrue( unsibscribeCancelBlockCalled_, @"OK" );
            nativeCancelBlockCalled_ = NO;
        }

        GHAssertFalse( nativeCancelBlockCalled_, @"operation_ should be canceled here" );
    }

    GHAssertTrue( 0 == [ JFFSimpleBlockHolder                  instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFCancelAsyncOperationBlockHolder    instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFAsyncOperationProgressBlockHolder  instancesCount ], @"OK" );
    GHAssertTrue( 0 == [ JFFDidFinishAsyncOperationBlockHolder instancesCount ], @"OK" );
}

@end
