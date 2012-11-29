#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#include <objc/objc.h>

@class NSArray;

@interface JFFAsyncTimerResult : NSObject
@end

#ifdef __cplusplus
extern "C" {
#endif

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

JFFAsyncOperation asyncOperationWithResult(id result);
JFFAsyncOperation asyncOperationWithError(NSError *error);

JFFAsyncOperation asyncOperationWithSyncOperationInCurrentQueue(JFFSyncOperation block);
    
//finish_callback_block_ called before loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishCallbackBlock(JFFAsyncOperation loader,
                                                        JFFDidFinishAsyncOperationHandler finishCallbackBlock);

//finish_callback_hook_ called instead loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishHookBlock(JFFAsyncOperation loader,
                                                    JFFDidFinishAsyncOperationHook finishCallbackHook);

JFFAsyncOperation asyncOperationWithStartAndFinishBlocks(JFFAsyncOperation loader,
                                                         JFFSimpleBlock startBlock,
                                                         JFFDidFinishAsyncOperationHandler finishCallback);

    JFFAsyncOperation asyncOperationWithStartAndDoneBlocks(JFFAsyncOperation loader,
                                                           JFFSimpleBlock startBlock,
                                                           JFFSimpleBlock doneBlock);

JFFAsyncOperation asyncOperationWithAnalyzer(id data, JFFAnalyzer analyzer);

JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer(JFFAnalyzer analyzer);

typedef id (^JFFChangedResultBuilder)(id result);
JFFAsyncOperation asyncOperationWithChangedResult(JFFAsyncOperation loader,
                                                  JFFChangedResultBuilder resultBuilder);

JFFAsyncOperation asyncOperationResultAsProgress(JFFAsyncOperation loader);

typedef NSError* (^JFFChangedErrorBuilder)(NSError *error);
JFFAsyncOperation asyncOperationWithChangedError(JFFAsyncOperation loader,
                                                 JFFChangedErrorBuilder errorBuilder);

JFFAsyncOperation asyncOperationWithResultOrError(JFFAsyncOperation loader,
                                                  id result,
                                                  NSError *error);

JFFAsyncOperation asyncOperationWithDelay(NSTimeInterval delay);

JFFAsyncOperation ignorePregressLoader(JFFAsyncOperation loader);
JFFAsyncOperationBinder ignorePregressBinder(JFFAsyncOperationBinder binder);

///////////////////////////////////// SEQUENCE /////////////////////////////////////

JFFAnalyzer analyzerAsSequenceOfAnalyzers(JFFAnalyzer firstAnalyzer, ...) NS_REQUIRES_NIL_TERMINATION;

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
