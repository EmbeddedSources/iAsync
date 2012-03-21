#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#include <objc/objc.h>

@class NSArray;

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

JFFAsyncOperation asyncOperationWithResult( id result_ );
JFFAsyncOperation asyncOperationWithError( NSError* error_ );

//finish_callback_block_ called before loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishCallbackBlock( JFFAsyncOperation loader_
                                                        , JFFDidFinishAsyncOperationHandler finishCallbackBlock_ );

//finish_callback_hook_ called instead loader_'s JFFDidFinishAsyncOperationHandler
JFFAsyncOperation asyncOperationWithFinishHookBlock( JFFAsyncOperation loader_
                                                    , JFFDidFinishAsyncOperationHook finishCallbackHook_ );

JFFAsyncOperation asyncOperationWithAnalyzer( id data_, JFFAnalyzer analyzer_ );

JFFAsyncOperationBinder asyncOperationBinderWithAnalyzer( JFFAnalyzer analyzer_ );

typedef id (^JFFChangedResultBuilder)(id result_);
JFFAsyncOperation asyncOperationWithChangedResult( JFFAsyncOperation loader_
                                                  , JFFChangedResultBuilder resultBuilder_ );

typedef NSError* (^JFFChangedErrorBuilder)(NSError* error_);
JFFAsyncOperation asyncOperationWithChangedError( JFFAsyncOperation loader_
                                                 , JFFChangedErrorBuilder errorBuilder_ );

JFFAsyncOperation asyncOperationWithResultOrError( JFFAsyncOperation loader_
                                                  , id result_
                                                  , NSError* error_ );

JFFAsyncOperation asyncOperationWithDelay( NSTimeInterval delay_ );

///////////////////////////////////// SEQUENCE /////////////////////////////////////

JFFAnalyzer analyzerAsSequenceOfAnalyzers( JFFAnalyzer firstAnalyzer_, ... );
