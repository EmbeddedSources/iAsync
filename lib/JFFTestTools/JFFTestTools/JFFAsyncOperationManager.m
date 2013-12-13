#import "JFFAsyncOperationManager.h"

#import <JFFAsyncOperations/JFFAsyncOperationHelpers.h>
#import <JFFAsyncOperations/JFFAsyncOperationsPredefinedBlocks.h>

#import <JFFAsyncOperations/Errors/JFFAsyncOperationAbstractFinishError.h>

@interface JFFAsyncOperationManager ()

@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback  loaderFinishBlock;
@property (nonatomic, copy) JFFAsyncOperationHandler loaderHandlerBlock;

@property (nonatomic) NSUInteger loadingCount;
@property (nonatomic) BOOL finished;
@property (nonatomic) BOOL canceled;
@property (nonatomic) JFFAsyncOperationHandlerTask lastHandleFlag;

@end

@implementation JFFAsyncOperationManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _lastHandleFlag = JFFAsyncOperationHandlerTaskUndefined;
    }
    
    return self;
}

- (void)clear
{
    _loaderFinishBlock  = nil;
    _loaderHandlerBlock = nil;
    _finished   = NO;
    _loadingCount = 0;
    
    _lastHandleFlag = JFFAsyncOperationHandlerTaskUndefined;
}

- (JFFAsyncOperation)loader
{
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        __weak JFFAsyncOperationManager *weakSelf = self;
        
        self.loadingCount += 1;
        
        if (self.cancelAtLoading > JFFDoNotCancelAsyncOperationManager) {
            
            self.canceled = YES;
            if (doneCallback) {
                
                JFFAsyncOperationHandlerTask task = (self.cancelAtLoading == JFFCancelAsyncOperationManagerWithNoFlag)
                ?JFFAsyncOperationHandlerTaskUnsubscribe
                :JFFAsyncOperationHandlerTaskCancel;
                NSError *error = [JFFAsyncOperationAbstractFinishError newAsyncOperationAbstractFinishErrorWithHandlerTask:task];
                doneCallback(nil, error);
            }
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        doneCallback = [doneCallback copy];
        
        self.loaderFinishBlock = ^(id result, NSError *error) {
            
            weakSelf.loaderFinishBlock  = nil;
            weakSelf.loaderHandlerBlock = nil;
            weakSelf.finished = YES;
            if (doneCallback)
                doneCallback(result, error);
        };
        
        if (self.finishAtLoading || self.failAtLoading) {
            if (self.finishAtLoading)
                self.loaderFinishBlock([NSNull null], nil);
            else
                self.loaderFinishBlock(nil, [JFFError newErrorWithDescription:@"some error"]);
            return JFFStubHandlerAsyncOperationBlock;
        }
        
        stateCallback = [stateCallback copy];
        self.loaderHandlerBlock = ^(JFFAsyncOperationHandlerTask task) {
            
            if (task <= JFFAsyncOperationHandlerTaskCancel) {
                weakSelf.loaderFinishBlock  = nil;
                weakSelf.loaderHandlerBlock = nil;
            }
            
            weakSelf.canceled       = (task <= JFFAsyncOperationHandlerTaskCancel);
            weakSelf.lastHandleFlag = task;
            
            processHandlerFlag(task, stateCallback, doneCallback);
        };
        
        return self.loaderHandlerBlock;
    };
}

@end
