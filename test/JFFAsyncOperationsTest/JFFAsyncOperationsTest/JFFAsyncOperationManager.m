#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>

@interface JFFAsyncOperationManager ()

@property ( nonatomic ) JFFDidFinishAsyncOperationBlockHolder* loaderFinishBlock;
@property ( nonatomic ) JFFCancelAsyncOperationBlockHolder* loaderCancelBlock;

@property ( nonatomic ) NSUInteger loadingCount;
@property ( nonatomic ) BOOL finished;
@property ( nonatomic ) BOOL canceled;
@property ( nonatomic ) BOOL cancelFlag;

@end

@implementation JFFAsyncOperationManager

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        self->_loaderFinishBlock = [ JFFDidFinishAsyncOperationBlockHolder new ];
        self->_loaderCancelBlock = [ JFFCancelAsyncOperationBlockHolder    new ];
    }

    return self;
}

-(void)clear
{
    self.loaderFinishBlock = nil;
    self.loaderCancelBlock = nil;
    self.finished = NO;
}

-(JFFAsyncOperation)loader
{
    return [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        self.loadingCount += 1;

        doneCallback_ = [ doneCallback_ copy ];

        __weak JFFAsyncOperationManager* self_ = self;

        self.loaderFinishBlock.didFinishBlock = ^( id result_, NSError* error_ )
        {
            //TODO use self instead of self_
            self_.loaderCancelBlock.cancelBlock = nil;
            self_.finished = YES;
            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };

        if ( self.finishAtLoading || self.failAtLoading )
        {
            if ( self.finishAtLoading )
                self.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
            else
                self.loaderFinishBlock.didFinishBlock( nil, [ JFFError newErrorWithDescription: @"some error" ] );
            return JFFStubCancelAsyncOperationBlock;
        }

        cancelCallback_ = [ cancelCallback_ copy ];
        self.loaderCancelBlock.cancelBlock = ^( BOOL canceled_ )
        {
            self.loaderFinishBlock.didFinishBlock = nil;
            self.canceled   = YES;
            self.cancelFlag = canceled_;
            if ( cancelCallback_ )
                cancelCallback_( canceled_ );
        };
        return self.loaderCancelBlock.onceCancelBlock;
    } copy ];
}

@end
