#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFUtils/Blocks/JFFUtilsBlockDefinitions.h>

#include <objc/objc.h>

@class NSArray;

#ifdef __cplusplus
extern "C" {
#endif

///////////////////////////////////// SEQUENCE /////////////////////////////////////

//calls loaders while success
    JFFAsyncOperation sequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                JFFAsyncOperation secondLoader, ...) NS_REQUIRES_NIL_TERMINATION;

    JFFAsyncOperation sequenceOfAsyncOperationsArray(NSArray *loaders);

/////////////////////////////// SEQUENCE WITH BINDING ///////////////////////////////

//calls binders while success
    JFFAsyncOperationBinder binderAsSequenceOfBinders(JFFAsyncOperationBinder firstBinder, ...) NS_REQUIRES_NIL_TERMINATION;

JFFAsyncOperationBinder binderAsSequenceOfBindersArray(NSArray *binders);

//calls binders while success
    JFFAsyncOperation bindSequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                    JFFAsyncOperationBinder secondLoaderBinder_, ...) NS_REQUIRES_NIL_TERMINATION;

    JFFAsyncOperation bindSequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader,
                                                         NSArray *loadersBinders);

/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

//calls loaders untill success
    JFFAsyncOperation trySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                   JFFAsyncOperation secondLoader, ...) NS_REQUIRES_NIL_TERMINATION;

    JFFAsyncOperation trySequenceOfAsyncOperationsArray(NSArray *loaders);

/////////////////////////////// TRY SEQUENCE WITH BINDING ///////////////////////////////

//calls loaders while success
//@@ next binder will receive an error if previous operation fails
    JFFAsyncOperation bindTrySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                       JFFAsyncOperationBinder secondLoaderBinder,
                                                       ...) NS_REQUIRES_NIL_TERMINATION;

//@@ next binder will receive an error if previous operation fails
    JFFAsyncOperation bindTrySequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader,
                                                            NSArray *loadersBinders);

/////////////////////////////////////// GROUP //////////////////////////////////////

//calls finish callback when all loaders finished
    JFFAsyncOperation groupOfAsyncOperations(JFFAsyncOperation firstLoader, ...) NS_REQUIRES_NIL_TERMINATION;

    JFFAsyncOperation groupOfAsyncOperationsArray(NSArray *loaders);

///////////////////////////// FAIL ON FIRST ERROR GROUP ////////////////////////////

//calls finish callback when all loaders success finished or when any of them is failed
    JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations(JFFAsyncOperation firstLoader, ...) NS_REQUIRES_NIL_TERMINATION;

    JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray(NSArray *loaders);

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

    //doneCallbackHook called an cancel or finish loader_'s callbacks
    JFFAsyncOperation asyncOperationWithDoneBlock(JFFAsyncOperation loader,
                                                  JFFSimpleBlock doneCallbackHook);

///////////////////////// AUTO REPEAT CIRCLE ////////////////////////
    
    JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation loader,
                                           JFFContinueLoaderWithResult continueLoaderBuilder,
                                           NSTimeInterval delay,
                                           NSInteger maxRepeatCount);
    
    JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                               JFFAsyncOperation loader);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
