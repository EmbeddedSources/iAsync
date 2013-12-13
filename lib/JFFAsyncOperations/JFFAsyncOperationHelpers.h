#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#include <objc/objc.h>

@class NSArray;

#ifdef __cplusplus
extern "C" {
#endif
    
///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

    JFFAsyncOperation asyncOperationWithResult(id result);
    JFFAsyncOperation asyncOperationWithError(NSError *error);
    JFFAsyncOperation asyncOperationWithHandlerFlag(JFFAsyncOperationHandlerTask task);
    JFFAsyncOperation neverFinishAsyncOperation(void);
    
    JFFAsyncOperation asyncOperationWithSyncOperationInCurrentQueue(JFFSyncOperation block);
    
    //finish_callback_block_ called before loader_'s JFFDidFinishAsyncOperationCallback
    JFFAsyncOperation asyncOperationWithFinishCallbackBlock(JFFAsyncOperation loader,
                                                            JFFDidFinishAsyncOperationCallback finishCallbackBlock);
    
    //finish_callback_hook_ called instead loader_'s JFFDidFinishAsyncOperationCallback
    JFFAsyncOperation asyncOperationWithFinishHookBlock(JFFAsyncOperation loader,
                                                        JFFDidFinishAsyncOperationHook finishCallbackHook);
    
    JFFAsyncOperation asyncOperationWithStartAndFinishBlocks(JFFAsyncOperation loader,
                                                             JFFSimpleBlock startBlock,
                                                             JFFDidFinishAsyncOperationCallback finishCallback);
    
    JFFAsyncOperation asyncOperationWithOptionalStartAndFinishBlocks(JFFAsyncOperation loader,
                                                                     JFFSimpleBlock startBlock,
                                                                     JFFDidFinishAsyncOperationCallback finishCallback);
    
    JFFAsyncOperation asyncOperationWithStartAndDoneBlocks(JFFAsyncOperation loader,
                                                           JFFSimpleBlock startBlock,
                                                           JFFSimpleBlock doneBlock);
    
    JFFAsyncOperation asyncOperationWithAnalyzer(id data, JFFAnalyzer analyzer);
    
    JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer(JFFAnalyzer analyzer);
    
    typedef id (^JFFChangedResultBuilder)(id result);
    JFFAsyncOperation asyncOperationWithChangedResult(JFFAsyncOperation loader,
                                                      JFFChangedResultBuilder resultBuilder);
    JFFAsyncOperation asyncOperationWithChangedProgress(JFFAsyncOperation loader,
                                                        JFFChangedResultBuilder resultBuilder);
    
    JFFAsyncOperation asyncOperationResultAsProgress(JFFAsyncOperation loader);
    
    typedef NSError *(^JFFChangedErrorBuilder)(NSError *error);
    JFFAsyncOperation asyncOperationWithChangedError(JFFAsyncOperation loader,
                                                     JFFChangedErrorBuilder errorBuilder);
    
    JFFAsyncOperation asyncOperationWithResultOrError(JFFAsyncOperation loader,
                                                      id result,
                                                      NSError *error);
    
    JFFAsyncOperation ignorePregressLoader(JFFAsyncOperation loader);
    JFFAsyncOperationBinder ignorePregressBinder(JFFAsyncOperationBinder binder);
    
    JFFAsyncOperation loaderWithAdditionalParalelLoaders(JFFAsyncOperation original, JFFAsyncOperation additionalLoader, ...) NS_REQUIRES_NIL_TERMINATION;
    
    ///////////////////////////////////// SEQUENCE /////////////////////////////////////
    
    JFFAnalyzer analyzerAsSequenceOfAnalyzers(JFFAnalyzer firstAnalyzer, ...) NS_REQUIRES_NIL_TERMINATION;
    
    void processHandlerFlag(JFFAsyncOperationHandlerTask task,
                            JFFAsyncOperationChangeStateCallback stateCallback,
                            JFFDidFinishAsyncOperationCallback doneCallback);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
