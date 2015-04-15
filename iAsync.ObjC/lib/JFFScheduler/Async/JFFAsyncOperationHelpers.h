#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <Foundation/Foundation.h>

@interface JFFAsyncTimerResult : NSObject
@end

#ifdef __cplusplus
extern "C" {
#endif
    
    JFFAsyncOperation asyncOperationWithDelay(NSTimeInterval delay,
                                              NSTimeInterval leeway);
    
    JFFAsyncOperation asyncOperationWithDelayWithDispatchQueue(NSTimeInterval delay,
                                                               NSTimeInterval leeway,
                                                               dispatch_queue_t callbacksQueue);
    
    JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                               NSTimeInterval leeway,
                                               JFFAsyncOperation loader);
    
    JFFAsyncOperation asyncOperationAfterDelayWithDispatchQueue(NSTimeInterval delay,
                                                                NSTimeInterval leeway,
                                                                JFFAsyncOperation loader,
                                                                dispatch_queue_t callbacksQueue);
    
    ///////////////////////// AUTO REPEAT CIRCLE ////////////////////////
    
    JFFAsyncOperation repeatAsyncOperationWithDelayLoader(JFFAsyncOperation nativeLoader,
                                                          JFFContinueLoaderWithResult continueLoaderBuilder,
                                                          NSInteger maxRepeatCount);
    
    JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation loader,
                                           JFFContinueLoaderWithResult continueLoaderBuilder,
                                           NSTimeInterval delay,
                                           NSTimeInterval leeway,
                                           NSInteger maxRepeatCount);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
