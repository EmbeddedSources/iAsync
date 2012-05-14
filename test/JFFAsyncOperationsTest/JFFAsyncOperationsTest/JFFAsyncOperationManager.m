#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>

@interface JFFAsyncOperationManager ()

@property ( nonatomic, retain ) JFFDidFinishAsyncOperationBlockHolder* loaderFinishBlock;
@property ( nonatomic, retain ) JFFCancelAsyncOperationBlockHolder* loaderCancelBlock;

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
        loaderCancelBlock = [ JFFCancelAsyncOperationBlockHolder    new ];
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
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        self.loadingCount += 1;

        doneCallback_ = [ doneCallback_ copy ];

        __block JFFAsyncOperationManager* self_ = self;

        self.loaderFinishBlock.didFinishBlock = ^( id result_, NSError* error_ )
        {
            //TODO use self instead of self_
            self_.loaderCancelBlock.cancelBlock = nil;
            self_.finished = YES;
            if ( doneCallback_ )
                doneCallback_( result_, error_ );
        };
        [ doneCallback_ release ];

        if ( self.finishAtLoading || self.failAtLoading )
        {
            if ( self.finishAtLoading )
                self.loaderFinishBlock.didFinishBlock( [ NSNull null ], nil );
            else
                self.loaderFinishBlock.didFinishBlock( nil, [ JFFError errorWithDescription: @"some error" ] );
            return JFFStubCancelAsyncOperationBlock;
        }

        cancelCallback_ = [ [ cancelCallback_ copy ] autorelease ];
        self.loaderCancelBlock.cancelBlock = ^( BOOL canceled_ )
        {
            self.loaderFinishBlock.didFinishBlock = nil;
            self.canceled   = YES;
            self.cancelFlag = canceled_;
            if ( cancelCallback_ )
                cancelCallback_( canceled_ );
        };
        return self.loaderCancelBlock.onceCancelBlock;
    } copy ] autorelease ];
}

@end
