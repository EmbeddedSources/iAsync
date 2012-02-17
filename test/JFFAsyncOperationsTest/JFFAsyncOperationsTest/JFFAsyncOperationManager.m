#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAyncOperationBlockHolder.h>

@interface JFFAsyncOperationManager ()

@property ( nonatomic, retain ) JFFDidFinishAsyncOperationBlockHolder* loaderFinishBlock;
@property ( nonatomic, retain ) JFFCancelAyncOperationBlockHolder* loaderCancelBlock;

@property ( nonatomic, assign ) NSUInteger loadingCount;
@property ( nonatomic, assign ) BOOL finished;
@property ( nonatomic, assign ) BOOL canceled;
@property ( nonatomic, assign ) BOOL cancelFlag;

@end

@implementation JFFAsyncOperationManager

@synthesize loaderFinishBlock;
@synthesize loaderCancelBlock;
@synthesize finished;
@synthesize canceled;
@synthesize cancelFlag;
@synthesize finishAtLoading;
@synthesize failAtLoading;
@synthesize loadingCount;

-(void)dealloc
{
    [ loaderFinishBlock release ];
    [ loaderCancelBlock release ];

    [ super dealloc ];
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        loaderFinishBlock = [ JFFDidFinishAsyncOperationBlockHolder new ];
        loaderCancelBlock = [ JFFCancelAyncOperationBlockHolder     new ];
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
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progress_callback_
                                        , JFFCancelAsyncOperationHandler cancel_callback_
                                        , JFFDidFinishAsyncOperationHandler done_callback_ )
    {
        self.loadingCount += 1;

        done_callback_ = [ done_callback_ copy ];

        __block JFFAsyncOperationManager* self_ = self;

        self.loaderFinishBlock.didFinishBlock = ^( id result_, NSError* error_ )
        {
            //TODO use self instead of self_
            self_.loaderCancelBlock.cancelBlock = nil;
            self_.finished = YES;
            if ( done_callback_ )
                done_callback_( result_, error_ );
        };
        [ done_callback_ release ];

        if ( self.finishAtLoading || self.failAtLoading )
        {
            if ( self.finishAtLoading )
                self.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
            else
                self.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );
            return JFFEmptyCancelAsyncOperationBlock;
        }

        cancel_callback_ = [ [ cancel_callback_ copy ] autorelease ];
        self.loaderCancelBlock.cancelBlock = ^( BOOL canceled_ )
        {
            self.loaderFinishBlock.didFinishBlock = nil;
            self.canceled = YES;
            self.cancelFlag = canceled_;
            if ( cancel_callback_ )
                cancel_callback_( canceled_ );
        };
        return self.loaderCancelBlock.onceCancelBlock;
    } copy ] autorelease ];
}

@end
