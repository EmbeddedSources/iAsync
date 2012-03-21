#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#include <objc/objc.h>

@class NSArray;

///////////////////////////////////// SEQUENCE /////////////////////////////////////

//calls loaders while success
JFFAsyncOperation sequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                            , JFFAsyncOperation secondLoader_, ... );

JFFAsyncOperation sequenceOfAsyncOperationsArray( NSArray* loaders_ );

/////////////////////////////// SEQUENCE WITH BINDING ///////////////////////////////

//calls binders while success
JFFAsyncOperationBinder binderAsSequenceOfBinders( JFFAsyncOperationBinder firstBinder_, ... );

JFFAsyncOperationBinder binderAsSequenceOfBindersArray( NSArray* binders_ );

//calls binders while success
JFFAsyncOperation bindSequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                                , JFFAsyncOperationBinder secondLoaderBinder_, ... );

JFFAsyncOperation bindSequenceOfAsyncOperationsArray( JFFAsyncOperation firstLoader
                                                     , NSArray* loadersBinders_ );

/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

//calls loaders untill success
JFFAsyncOperation trySequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                               , JFFAsyncOperation secondLoader_, ... );

JFFAsyncOperation trySequenceOfAsyncOperationsArray( NSArray* loaders_ );

/////////////////////////////// TRY SEQUENCE WITH BINDING ///////////////////////////////

//calls loaders while success
JFFAsyncOperation bindTrySequenceOfAsyncOperations( JFFAsyncOperation firstLoader_
                                                   , JFFAsyncOperationBinder secondLoaderBinder_, ... );

JFFAsyncOperation bindTrySequenceOfAsyncOperationsArray( JFFAsyncOperation firstLoader_
                                                        , NSArray* loadersBinders_ );

/////////////////////////////////////// GROUP //////////////////////////////////////

//calls finish callback when all loaders finished
//result of group is undefined for success result
JFFAsyncOperation groupOfAsyncOperations( JFFAsyncOperation firstLoader_, ... );

JFFAsyncOperation groupOfAsyncOperationsArray( NSArray* loaders_ );

///////////////////////////// FAIL ON FIRST ERROR GROUP ////////////////////////////

//calls finish callback when all loaders success finished or when any of them is failed
//result of group is undefined for success result
JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations( JFFAsyncOperation firstLoader_, ... );

JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray( NSArray* loaders_ );

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

//done_callback_hook_ called an cancel or finish loader_'s callbacks
JFFAsyncOperation asyncOperationWithDoneBlock( JFFAsyncOperation loader_
                                              , JFFSimpleBlock doneCallbackHook_ );

///////////////////////// AUTO REPEAT CIRCLE ////////////////////////

JFFAsyncOperation repeatAsyncOperation( JFFAsyncOperation loader_
                                       , PredicateBlock predicate_
                                       , NSTimeInterval delay_
                                       , NSInteger max_repeat_count_ );

JFFAsyncOperation asyncOperationAfterDelay( NSTimeInterval delay_
                                           , JFFAsyncOperation loader_ );
