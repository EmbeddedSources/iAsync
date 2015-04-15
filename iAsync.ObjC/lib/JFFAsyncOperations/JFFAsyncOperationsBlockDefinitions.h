#ifndef __JASYNC__BLOCK_DEFINITIONS_H__
#define __JASYNC__BLOCK_DEFINITIONS_H__

#import <Foundation/Foundation.h>
#include <JFFAsyncOperations/JFFAsyncOperationHandlerTask.h>
#include <JFFAsyncOperations/JFFAsyncOperationState.h>

@class NSError;

typedef void (^JFFAsyncOperationProgressCallback)(id progressInfo);

//Synchronous block which can take a lot of time
typedef id (^JFFSyncOperation)(NSError *__autoreleasing *outError);

//This block should call progress_callback_ block only from own thread
typedef id (^JFFSyncOperationWithProgress)(NSError *__autoreleasing *error,
                                           JFFAsyncOperationProgressCallback progressCallback);

typedef void (^JFFDidFinishAsyncOperationCallback)(id result, NSError *error);

typedef void (^JFFAsyncOperationHandler)(JFFAsyncOperationHandlerTask task);

typedef void (^JFFAsyncOperationChangeStateCallback)(JFFAsyncOperationState state);

//@@ progressCallback -- nil | valid block
//@@ stateCallback    -- nil | valid block
//@@ doneCallback     -- nil | valid block
typedef JFFAsyncOperationHandler (^JFFAsyncOperation)(JFFAsyncOperationProgressCallback progressCallback,
                                                      JFFAsyncOperationChangeStateCallback stateCallback,
                                                      JFFDidFinishAsyncOperationCallback doneCallback);

//@@ next binder receives the result of the previous operation
//@@ next binder may receive an error if previous operation fails and the binder gets called
typedef JFFAsyncOperation (^JFFAsyncOperationBinder)(id result);

typedef void (^JFFDidFinishAsyncOperationHook)(id result,
                                               NSError *error,
                                               JFFDidFinishAsyncOperationCallback doneCallback);

typedef JFFAsyncOperation (^JFFContinueLoaderWithResult)(id result, NSError *error);

#endif //__JASYNC__BLOCK_DEFINITIONS_H__
