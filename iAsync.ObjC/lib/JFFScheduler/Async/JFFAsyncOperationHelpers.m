#import "JFFAsyncOperationHelpers.h"

#import "JFFTimer.h"

#import <JFFAsyncOperations/Errors/JFFAsyncOpFinishedByCancellationError.h>
#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>
#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationInterface.h>

#import <JFFAsyncOperations/JFFAsyncOperationHelpers.h>
#import <JFFAsyncOperations/JFFAsyncOperationContinuity.h>

@implementation JFFAsyncTimerResult : NSObject
@end

@interface JFFAsyncOperationScheduler : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncOperationScheduler
{
    JFFTimer *_timer;
    JFFDidFinishAsyncOperationCallback _finishCallback;
@public
    NSTimeInterval _duration;
    NSTimeInterval _leeway;
    dispatch_queue_t _callbacksQueue;
}

- (void)startIfNeeds
{
    if (_timer)
        return;
    
    __unsafe_unretained JFFAsyncOperationScheduler *unsafeUnretainedSelf = self;
    
    _timer = [JFFTimer new];
    [_timer addBlock:^(JFFCancelScheduledBlock cancel) {
        
        cancel();
        
        JFFDidFinishAsyncOperationCallback finishCallback = unsafeUnretainedSelf->_finishCallback;
        
        if (finishCallback)
            finishCallback([JFFAsyncTimerResult new], nil);
    } duration:_duration leeway:_leeway dispatchQueue:_callbacksQueue];
}

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    _finishCallback = finishCallback;
    
    [self startIfNeeds];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    switch (task) {
            
        case JFFAsyncOperationHandlerTaskUnSubscribe:
        case JFFAsyncOperationHandlerTaskCancel:
        case JFFAsyncOperationHandlerTaskSuspend:
        {
            _timer = nil;
            break;
        }
        case JFFAsyncOperationHandlerTaskResume:
        {
            [self startIfNeeds];
            break;
        }
        default:
        {
            NSAssert1(NO, @"invalid parameter: %lu", (unsigned long)task);
            break;
        }
    }
}

@end

JFFAsyncOperation asyncOperationWithDelay(NSTimeInterval delay, NSTimeInterval leeway)
{
    NSCAssert([NSThread isMainThread], @"main thread expected");
    return asyncOperationWithDelayWithDispatchQueue(delay, leeway, dispatch_get_main_queue());
}

JFFAsyncOperation asyncOperationWithDelayWithDispatchQueue(NSTimeInterval delay, NSTimeInterval leeway, dispatch_queue_t callbacksQueue)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        
        JFFAsyncOperationScheduler *asyncObject = [JFFAsyncOperationScheduler new];
        asyncObject->_duration       = delay;
        asyncObject->_leeway         = leeway;
        asyncObject->_callbacksQueue = callbacksQueue;
        return asyncObject;
    };
    return buildAsyncOperationWithAdapterFactoryWithDispatchQueue(factory, callbacksQueue);
}

JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                           NSTimeInterval leeway,
                                           JFFAsyncOperation loader)
{
    NSCAssert([NSThread isMainThread], @"main thread expected");
    return asyncOperationAfterDelayWithDispatchQueue(delay,
                                                     leeway,
                                                     loader,
                                                     dispatch_get_main_queue());
}

JFFAsyncOperation asyncOperationAfterDelayWithDispatchQueue(NSTimeInterval delay,
                                                            NSTimeInterval leeway,
                                                            JFFAsyncOperation loader,
                                                            dispatch_queue_t callbacksQueue)
{
    return sequenceOfAsyncOperations(asyncOperationWithDelayWithDispatchQueue(delay, leeway, callbacksQueue), loader, nil);
}

JFFAsyncOperation repeatAsyncOperationWithDelayLoader(JFFAsyncOperation nativeLoader,
                                                      JFFContinueLoaderWithResult continueLoaderBuilder,
                                                      NSInteger maxRepeatCount)
{
    NSCParameterAssert(nativeLoader         );//can not be nil
    NSCParameterAssert(continueLoaderBuilder);//can not be nil
    
    nativeLoader          = [nativeLoader          copy];
    continueLoaderBuilder = [continueLoaderBuilder copy];
    
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        progressCallback = [progressCallback copy];
        stateCallback    = [stateCallback    copy];
        doneCallback     = [doneCallback     copy];
        
        __block JFFAsyncOperationHandler currentLoaderHandlerHolder;
        __block JFFDidFinishAsyncOperationHook finishHookHolder;
        
        __block JFFAsyncOperationProgressCallback    progressCallbackHolder = [progressCallback copy];
        __block JFFAsyncOperationChangeStateCallback stateCallbackHolder    = [stateCallback    copy];
        __block JFFDidFinishAsyncOperationCallback   doneCallbackHolder     = [doneCallback     copy];
        
        JFFAsyncOperationProgressCallback progressCallbackWrapper = ^(id progressInfo) {
            
            if (progressCallbackHolder)
                progressCallbackHolder(progressInfo);
        };
        JFFAsyncOperationChangeStateCallback stateCallbackWrapper = ^(JFFAsyncOperationState state) {
            
            if (stateCallbackHolder)
                stateCallbackHolder(state);
        };
        JFFDidFinishAsyncOperationCallback doneCallbackkWrapper = ^(id result, NSError *error) {
            
            if (doneCallbackHolder) {
                doneCallbackHolder(result, error);
                doneCallbackHolder = nil;
            }
        };
        
        __block NSInteger currentLeftCount = maxRepeatCount;
        
        void (^clearCallbacks)(void) = ^() {
            progressCallbackHolder = nil;
            stateCallbackHolder    = nil;
            doneCallbackHolder     = nil;
        };
        
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(id result,
                                                              NSError *error,
                                                              JFFDidFinishAsyncOperationCallback doneCallback) {
            
            void (^finish)(void) = ^() {
                
                finishHookHolder = nil;
                doneCallbackkWrapper(result, error);
                
                clearCallbacks();
            };
            
            if ([error isKindOfClass:[JFFAsyncOpFinishedByCancellationError class]]) {
                
                finish();
                return;
            }
            
            JFFAsyncOperation newLoader = continueLoaderBuilder(result, error);
            
            if (!newLoader || currentLeftCount == 0) {
                
                finish();
            } else {
                
                currentLeftCount = currentLeftCount > 0
                ?currentLeftCount - 1
                :currentLeftCount;
                
                JFFAsyncOperation loader = asyncOperationWithFinishHookBlock(newLoader, finishHookHolder);
                
                currentLoaderHandlerHolder = loader(progressCallbackWrapper, stateCallbackWrapper, doneCallbackkWrapper);
            }
        };
        
        finishHookHolder = [finishCallbackHook copy];
        
        JFFAsyncOperation loader = asyncOperationWithFinishHookBlock(nativeLoader,
                                                                     finishHookHolder);
        
        currentLoaderHandlerHolder = loader(progressCallback, stateCallbackWrapper, doneCallbackkWrapper);
        
        return ^void(JFFAsyncOperationHandlerTask task) {
            
            if (task == JFFAsyncOperationHandlerTaskCancel)
                finishHookHolder = nil;
            
            if (!currentLoaderHandlerHolder)
                return;
            
            if (task != JFFAsyncOperationHandlerTaskUnSubscribe)
                currentLoaderHandlerHolder(task);
            
            if (task == JFFAsyncOperationHandlerTaskCancel)
                currentLoaderHandlerHolder = nil;
            
            if (task == JFFAsyncOperationHandlerTaskUnSubscribe) {
                
                clearCallbacks();
            }
        };
    };
}

JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation nativeLoader,
                                       JFFContinueLoaderWithResult continueLoaderBuilder,
                                       NSTimeInterval delay,
                                       NSTimeInterval leeway,
                                       NSInteger maxRepeatCount)
{
    continueLoaderBuilder = [continueLoaderBuilder copy];
    JFFContinueLoaderWithResult continueLoaderBuilderWrapper = ^JFFAsyncOperation(id result, NSError *error) {
        
        JFFAsyncOperation loader = continueLoaderBuilder(result, error);
        if (!loader)
            return nil;
        
        return sequenceOfAsyncOperations(asyncOperationWithDelay(delay, leeway), loader, nil);
    };
    
    return repeatAsyncOperationWithDelayLoader(nativeLoader,
                                               continueLoaderBuilderWrapper,
                                               maxRepeatCount);
}
