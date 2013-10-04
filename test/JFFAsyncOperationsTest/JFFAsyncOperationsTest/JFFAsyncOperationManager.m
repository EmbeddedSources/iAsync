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

- (JFFDidFinishAsyncOperationBlockHolder *)loaderFinishBlock
{
    if (!_loaderFinishBlock) {
        
        _loaderFinishBlock = [JFFDidFinishAsyncOperationBlockHolder new];
    }
    
    return _loaderFinishBlock;
}

- (JFFCancelAsyncOperationBlockHolder *)loaderCancelBlock
{
    if (!_loaderCancelBlock) {
        
        _loaderCancelBlock = [JFFCancelAsyncOperationBlockHolder new];
    }
    
    return _loaderCancelBlock;
}

- (void)clear
{
    self.loaderFinishBlock = nil;
    self.loaderCancelBlock = nil;
    self.finished = NO;
}

- (JFFAsyncOperation)loader
{
    __weak JFFAsyncOperationManager *weakSelf = self;
    
    return [^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progress_callback,
                                      JFFCancelAsyncOperationHandler cancelCallback,
                                      JFFDidFinishAsyncOperationHandler doneCallback) {
        
        self.loadingCount += 1;
        
        if (self.cancelAtLoading > JFFDoNotCancelAsyncOperationManager) {
            
            self.canceled   = YES;
            if (cancelCallback)
                cancelCallback(JFFCancelAsyncOperationManagerWithYesFlag == self.cancelAtLoading);
            return JFFStubCancelAsyncOperationBlock;
        }
        
        doneCallback = [doneCallback copy];
        
        self.loaderFinishBlock.didFinishBlock = ^(id result, NSError *error) {
            
            weakSelf.loaderFinishBlock.didFinishBlock = nil;
            weakSelf.loaderCancelBlock.cancelBlock = nil;
            weakSelf.finished = YES;
            if (doneCallback)
                doneCallback(result, error);
        };
        
        if (self.finishAtLoading || self.failAtLoading) {
            if (self.finishAtLoading)
                self.loaderFinishBlock.didFinishBlock([NSNull null], nil);
            else
                self.loaderFinishBlock.didFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
            return JFFStubCancelAsyncOperationBlock;
        }
        
        cancelCallback = [cancelCallback copy];
        self.loaderCancelBlock.cancelBlock = ^(BOOL canceled) {
            weakSelf.loaderFinishBlock.didFinishBlock = nil;
            weakSelf.canceled   = YES;
            weakSelf.cancelFlag = canceled;
            if (cancelCallback)
                cancelCallback(canceled);
        };
        return self.loaderCancelBlock.onceCancelBlock;
    } copy];
}

@end
