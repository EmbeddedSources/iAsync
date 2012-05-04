#import "NSObject+AutoCancelAsyncOperation.h"

#import "JFFAsyncOperationsPredefinedBlocks.h"

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

        JFFSimpleBlockHolder* removeOndeallocBlockJolder_ = [ JFFSimpleBlockHolder new ];
        removeOndeallocBlockJolder_.simpleBlock = ^void( void )
        {
            finished_ = YES;

            if ( ondeallocBlockHolder_.simpleBlock )
            {
                [ self_ removeOnDeallocBlock: ondeallocBlockHolder_.simpleBlock ];
                ondeallocBlockHolder_.simpleBlock = nil;
            }
        };

        __block JFFCancelAsyncOperation cancelCallbackHolder_;
        cancelCallbackHolder_ = [ cancelCallback_ copy ];
        JFFCancelAsyncOperationHandler cancelCallbackWrapper_ = ^void( BOOL cancelOp_ )
        {
            removeOndeallocBlockJolder_.onceSimpleBlock();
            if ( cancelCallbackHolder_ )
            {
                cancelCallbackHolder_( cancelOp_ );
                cancelCallbackHolder_ = nil;
            }
        };

        JFFDidFinishAsyncOperationBlockHolder* doneCallbackHolder_ = [ JFFDidFinishAsyncOperationBlockHolder new ];
        doneCallbackHolder_.didFinishBlock = doneCallback_;
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper_ = ^void( id result_, NSError* error_ )
        {
            removeOndeallocBlockJolder_.onceSimpleBlock();
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

        __block JFFCancelAsyncOperation cancelBlockHolder_ = [ ^void( BOOL canceled_ )
        {
            cancel_( canceled_ );
        } copy ];

        return ^( BOOL canceled_ )
        {
            if ( !cancelBlockHolder_ )
                return;
            cancelBlockHolder_( canceled_ );
            cancelBlockHolder_ = nil;
        };
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
