#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/Helpers/JFFDidFinishAsyncOperationBlockHolder.h>
#import <JFFAsyncOperations/Helpers/JFFCancelAsyncOperationBlockHolder.h>

@interface JFFAsyncOperationManager ()

@property (nonatomic) JFFDidFinishAsyncOperationBlockHolder *loaderFinishBlock;
@property (nonatomic) JFFCancelAsyncOperationBlockHolder    *loaderCancelBlock;

@property (nonatomic) NSUInteger loadingCount;
@property (nonatomic) BOOL finished;
@property (nonatomic) BOOL canceled;
@property (nonatomic) BOOL cancelFlag;

@end

@implementation JFFAsyncOperationManager

-(id)init
{
    self = [ super init ];
    
    if (self) {
        self->_loaderFinishBlock = [JFFDidFinishAsyncOperationBlockHolder new];
        self->_loaderCancelBlock = [JFFCancelAsyncOperationBlockHolder    new];
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
    return [ ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progress_callback,
                                      JFFCancelAsyncOperationHandler cancelCallback,
                                      JFFDidFinishAsyncOperationHandler doneCallback) {
        self.loadingCount += 1;
        
        doneCallback = [doneCallback copy];
        
        self.loaderFinishBlock.didFinishBlock = ^( id result_, NSError* error_ ) {
            self.loaderFinishBlock.didFinishBlock = nil;
            self.loaderCancelBlock.cancelBlock = nil;
            self.finished = YES;
            if (doneCallback)
                doneCallback( result_, error_ );
        };
        
        if (self.finishAtLoading || self.failAtLoading) {
            if ( self.finishAtLoading )
                self.loaderFinishBlock.didFinishBlock([NSNull null], nil);
            else
                self.loaderFinishBlock.didFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
            return JFFStubCancelAsyncOperationBlock;
        }
        
        cancelCallback = [cancelCallback copy];
        self.loaderCancelBlock.cancelBlock = ^(BOOL canceled) {
            self.loaderFinishBlock.didFinishBlock = nil;
            self.canceled   = YES;
            self.cancelFlag = canceled;
            if (cancelCallback)
                cancelCallback(canceled);
        };
        return self.loaderCancelBlock.onceCancelBlock;
    } copy ];
}

@end
