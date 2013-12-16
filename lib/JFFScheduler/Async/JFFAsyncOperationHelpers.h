#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <Foundation/Foundation.h>

@interface JFFAsyncTimerResult : NSObject
@end

#ifdef __cplusplus
extern "C" {
#endif
    
    JFFAsyncOperation asyncOperationWithDelay(NSTimeInterval delay, NSTimeInterval leeway);
    
    JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                               NSTimeInterval leeway,
                                               JFFAsyncOperation loader);
    
    ///////////////////////// AUTO REPEAT CIRCLE ////////////////////////
    
    JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation loader,
                                           JFFContinueLoaderWithResult continueLoaderBuilder,
                                           NSTimeInterval delay,
                                           NSTimeInterval leeway,
                                           NSInteger maxRepeatCount);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
