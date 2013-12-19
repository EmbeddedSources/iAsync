#import "JFFTimerHelpers.h"

#import "JFFTimer.h"

#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>
#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationInterface.h>


#import <JFFAsyncOperations/JFFAsyncOperationContinuity.h>

#import <JFFAsyncOperations/JFFAsyncOperationHelpers.h>
#import <JFFScheduler/Async/JFFTimerHelpers.h>

@implementation JFFAsyncTimerResult : NSObject
@end

@interface JFFAsyncOperationScheduler : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncOperationScheduler
{
    JFFTimer *_timer;
@public
    NSTimeInterval _duration;
    NSTimeInterval _leeway;
}

- (void)asyncOperationWithResultHandler:(void(^)(id, NSError *))handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    _timer = [JFFTimer new];
    [_timer addBlock:^(JFFCancelScheduledBlock cancel) {
        
        cancel();
        if (handler)
            handler([JFFAsyncTimerResult new], nil);
    } duration:_duration leeway:_leeway];
}

- (void)cancel:(BOOL)canceled
{
    _timer = nil;
}

@end

JFFAsyncOperation asyncOperationWithDelay(NSTimeInterval delay, NSTimeInterval leeway)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        
        JFFAsyncOperationScheduler *asyncObject = [JFFAsyncOperationScheduler new];
        asyncObject->_duration = delay;
        asyncObject->_leeway   = leeway;
        return asyncObject;
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}

JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                           NSTimeInterval leeway,
                                           JFFAsyncOperation loader)
{
    return sequenceOfAsyncOperations(asyncOperationWithDelay(delay, leeway), loader, nil);
}


//TODO test it, on leaks also
JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation nativeLoader,
                                       JFFContinueLoaderWithResult continueLoaderBuilder,
                                       NSTimeInterval delay,
                                       NSTimeInterval leeway,
                                       NSInteger maxRepeatCount)
{
    NSCParameterAssert(nativeLoader         );//can not be nil
    NSCParameterAssert(continueLoaderBuilder);//can not be nil
    
    nativeLoader          = [nativeLoader          copy];
    continueLoaderBuilder = [continueLoaderBuilder copy];
    
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        progressCallback = [progressCallback copy];
        cancelCallback   = [cancelCallback   copy];
        doneCallback     = [doneCallback     copy];
        
        __block JFFCancelAsyncOperation cancelBlockHolder;
        
        __block JFFDidFinishAsyncOperationHook finishHookHolder;
        
        __block NSInteger currentLeftCount = maxRepeatCount;
        
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(id result,
                                                              NSError *error,
                                                              JFFDidFinishAsyncOperationHandler doneCallback) {
            
            JFFAsyncOperation newLoader = continueLoaderBuilder(result, error);
            if (!newLoader || currentLeftCount == 0) {
                finishHookHolder = nil;
                if (doneCallback)
                    doneCallback(result, error);
            } else {
                currentLeftCount = currentLeftCount > 0
                ?currentLeftCount - 1
                :currentLeftCount;
                
                JFFAsyncOperation loader = asyncOperationWithFinishHookBlock(newLoader,
                                                                             finishHookHolder);
                loader = asyncOperationAfterDelay(delay, leeway, loader);
                
                cancelBlockHolder = loader(progressCallback, cancelCallback, doneCallback);
            }
        };
        
        finishHookHolder = [finishCallbackHook copy];
        
        JFFAsyncOperation loader = asyncOperationWithFinishHookBlock(nativeLoader,
                                                                     finishHookHolder);
        
        cancelBlockHolder = loader(progressCallback, cancelCallback, doneCallback);
        
        return ^(BOOL canceled) {
            finishHookHolder = nil;
            
            if (!cancelBlockHolder)
                return;
            cancelBlockHolder(canceled);
            cancelBlockHolder = nil;
        };
    };
}
