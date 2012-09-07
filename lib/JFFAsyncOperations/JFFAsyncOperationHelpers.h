#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#include <objc/objc.h>

@class NSArray;

#ifdef __cplusplus
extern "C" {
#endif

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

JFFAsyncOperation asyncOperationWithResult( id result_ );
JFFAsyncOperation asyncOperationWithError( NSError* error_ );

JFFAsyncOperation currentQeueAsyncOpWithResult( JFFSyncOperation block_ );
    
//finish_callback_block_ called before loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finishCallbackBlock_ );

//finish_callback_hook_ called instead loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finishCallbackHook_ );

JFFAsyncOperation asyncOperationWithStartAndFinishBlocks( JFFAsyncOperation loader_
                                                         , JFFSimpleBlock startBlock_
                                                         , JFFDidFinishAsyncOperationHandler finishCallback_ );

JFFAsyncOperation asyncOperationWithAnalyzer( id data_, JFFAnalyzer analyzer_ );

JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer( JFFAnalyzer analyzer_ );

typedef id (^JFFChangedResultBuilder)(id result_);
JFFAsyncOperation asyncOperationWithChangedResult( JFFAsyncOperation loader_
                                                  , JFFChangedResultBuilder resultBuilder_ );

JFFAsyncOperation asyncOperationResultAsProgress( JFFAsyncOperation loader_ );

typedef NSError* (^JFFChangedErrorBuilder)(NSError* error_);
JFFAsyncOperation asyncOperationWithChangedError( JFFAsyncOperation loader_
                                                 , JFFChangedErrorBuilder errorBuilder_ );

JFFAsyncOperation asyncOperationWithResultOrError( JFFAsyncOperation loader_
                                                  , id result_
                                                  , NSError* error_ );

JFFAsyncOperation asyncOperationWithDelay( NSTimeInterval delay_ );

JFFAsyncOperation ignorePregressLoader( JFFAsyncOperation loader_ );

///////////////////////////////////// SEQUENCE /////////////////////////////////////

JFFAnalyzer analyzerAsSequenceOfAnalyzers( JFFAnalyzer firstAnalyzer_, ... ) NS_REQUIRES_NIL_TERMINATION;

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
