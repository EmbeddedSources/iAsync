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
                                                JFFAsyncOperation secondLoader, ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));
    
    JFFAsyncOperation sequenceOfAsyncOperationsArray(NSArray *loaders) __attribute__((pure,const));
    
/////////////////////////////// SEQUENCE WITH BINDING ///////////////////////////////

//calls binders while success
    JFFAsyncOperationBinder binderAsSequenceOfBinders(JFFAsyncOperationBinder firstBinder, ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));
    
    JFFAsyncOperationBinder binderAsSequenceOfBindersArray(NSArray *binders);
    
//calls binders while success
    JFFAsyncOperation bindSequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                    JFFAsyncOperationBinder secondLoaderBinder_, ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));
    
    JFFAsyncOperation bindSequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader,
                                                         NSArray *loadersBinders) __attribute__((pure,const));
    
/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

//calls loaders untill success
    JFFAsyncOperation trySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                   JFFAsyncOperation secondLoader, ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));
    
    JFFAsyncOperation trySequenceOfAsyncOperationsArray(NSArray *loaders) __attribute__((pure,const));
    
/////////////////////////////// TRY SEQUENCE WITH BINDING ///////////////////////////////
    
//calls loaders while success
//@@ next binder will receive an error if previous operation fails
    JFFAsyncOperation bindTrySequenceOfAsyncOperations(JFFAsyncOperation firstLoader,
                                                       JFFAsyncOperationBinder secondLoaderBinder,
                                                       ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));
    
//@@ next binder will receive an error if previous operation fails
    JFFAsyncOperation bindTrySequenceOfAsyncOperationsArray(JFFAsyncOperation firstLoader,
                                                            NSArray *loadersBinders) __attribute__((pure,const));
    
/////////////////////////////////////// GROUP //////////////////////////////////////
    
//calls finish callback when all loaders finished
    JFFAsyncOperation groupOfAsyncOperations(JFFAsyncOperation firstLoader, ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));
    
    JFFAsyncOperation groupOfAsyncOperationsArray(NSArray *loaders) __attribute__((pure,const));
    
///////////////////////////// FAIL ON FIRST ERROR GROUP ////////////////////////////

//calls finish callback when all loaders success finished or when any of them is failed
    JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperations(JFFAsyncOperation firstLoader, ...) NS_REQUIRES_NIL_TERMINATION __attribute__((pure,const));

    JFFAsyncOperation failOnFirstErrorGroupOfAsyncOperationsArray(NSArray *loaders) __attribute__((pure,const));

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

    //doneCallbackHook called an cancel or finish loader_'s callbacks
    JFFAsyncOperation asyncOperationWithDoneBlock(JFFAsyncOperation loader,
                                                  JFFSimpleBlock doneCallbackHook) __attribute__((pure,const));

///////////////////////// AUTO REPEAT CIRCLE ////////////////////////
    
    JFFAsyncOperation repeatAsyncOperation(JFFAsyncOperation loader,
                                           JFFContinueLoaderWithResult continueLoaderBuilder,
                                           NSTimeInterval delay,
                                           NSInteger maxRepeatCount) __attribute__((pure,const));
    
    JFFAsyncOperation asyncOperationAfterDelay(NSTimeInterval delay,
                                               JFFAsyncOperation loader) __attribute__((pure,const));

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
