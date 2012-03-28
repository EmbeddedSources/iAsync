#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"

#import "JFFCancelAyncOperationBlockHolder.h"
#import "JFFDidFinishAsyncOperationBlockHolder.h"

@implementation NSObject (WeakAsyncOperation)

-(JFFAsyncOperation)autoUnsibscribeOrCancelAsyncOperation:( JFFAsyncOperation )nativeAsyncOp_
                                                   cancel:( BOOL )cancelNativeAsyncOp_
{
    NSParameterAssert( nativeAsyncOp_ );

    nativeAsyncOp_ = [ nativeAsyncOp_ copy ];
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                    , JFFCancelAsyncOperationHandler cancelCallback_
                                    , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        __block BOOL finished_ = NO;
        __unsafe_unretained id self_ = self;

        JFFSimpleBlockHolder* ondeallocBlockHolder_ = [ JFFSimpleBlockHolder new ];

        JFFSimpleBlockHolder* remove_ondealloc_block_holder_ = [ JFFSimpleBlockHolder new ];
        remove_ondealloc_block_holder_.simpleBlock = ^void( void )
        {
            finished_ = YES;

            if ( ondeallocBlockHolder_.simpleBlock )
            {
                [ self_ removeOnDeallocBlock: ondeallocBlockHolder_.simpleBlock ];
                ondeallocBlockHolder_.simpleBlock = nil;
            }
        };

        JFFCancelAyncOperationBlockHolder* cancel_callback_holder_ = [ JFFCancelAyncOperationBlockHolder new ];
        cancel_callback_holder_.cancelBlock = cancelCallback_;
        JFFCancelAsyncOperationHandler cancelCallbackWrapper_ = ^void( BOOL cancel_op_ )
        {
            remove_ondealloc_block_holder_.onceSimpleBlock();
            cancel_callback_holder_.onceCancelBlock( cancel_op_ );
        };

        JFFDidFinishAsyncOperationBlockHolder* doneCallbackHolder_ = [ JFFDidFinishAsyncOperationBlockHolder new ];
        doneCallbackHolder_.didFinishBlock = doneCallback_;
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper_ = ^void( id result_
                                                                        , NSError* error_ )
        {
            remove_ondealloc_block_holder_.onceSimpleBlock();
            doneCallbackHolder_.onceDidFinishBlock( result_, error_ );
        };

        JFFCancelAsyncOperation cancel_ = nativeAsyncOp_( progressCallback_
                                                         , cancelCallbackWrapper_
                                                         , doneCallbackWrapper_ );

        if ( finished_ )
        {
            return JFFStubCancelAsyncOperationBlock;
        }

        ondeallocBlockHolder_.simpleBlock = ^void( void )
        {
            cancel_( cancelNativeAsyncOp_ );
        };

        //try assert retain count
        [ self addOnDeallocBlock: ondeallocBlockHolder_.simpleBlock ];

        JFFCancelAyncOperationBlockHolder* mainCancelHolder_ = [ JFFCancelAyncOperationBlockHolder new ];
        mainCancelHolder_.cancelBlock = ^void( BOOL canceled_ )
        {
            cancel_( canceled_ );
        };

        return mainCancelHolder_.onceCancelBlock;
    };
}

-(JFFAsyncOperation)autoUnsubsribeOnDeallocAsyncOperation:( JFFAsyncOperation )native_async_op_
{
    return [ self autoUnsibscribeOrCancelAsyncOperation: native_async_op_
                                                 cancel: NO ];
}

-(JFFAsyncOperation)autoCancelOnDeallocAsyncOperation:( JFFAsyncOperation )native_async_op_
{
    return [ self autoUnsibscribeOrCancelAsyncOperation: native_async_op_
                                                 cancel: YES ];
}

@end
