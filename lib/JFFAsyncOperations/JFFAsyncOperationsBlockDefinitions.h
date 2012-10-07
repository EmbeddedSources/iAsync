#ifndef __JASYNC__BLOCK_DEFINITIONS_H__
#define __JASYNC__BLOCK_DEFINITIONS_H__

#import <Foundation/Foundation.h>

@class NSError;

typedef void (^JFFAsyncOperationProgressHandler)(id progressInfo);

//Synchronous block which can take a lot of time
typedef id (^JFFSyncOperation)(NSError *__autoreleasing *outError);

//This block should call progress_callback_ block only from own thread
typedef id (^JFFSyncOperationWithProgress)(NSError *__autoreleasing *error,
                                           JFFAsyncOperationProgressHandler progressCallback);

typedef void (^JFFDidFinishAsyncOperationHandler)(id result, NSError *error);

typedef void (^JFFCancelAsyncOperation)(BOOL unsubscribeOnlyIfNo);

typedef JFFCancelAsyncOperation JFFCancelAsyncOperationHandler;

//@@ progressCallback -- nil | valid block
//@@ cancelCallback   -- nil | valid block
//@@ doneCallback     -- nil | valid block
typedef JFFCancelAsyncOperation (^JFFAsyncOperation)(JFFAsyncOperationProgressHandler progressCallback,
                                                     JFFCancelAsyncOperationHandler cancelCallback,
                                                     JFFDidFinishAsyncOperationHandler doneCallback);

//@@ next binder receives the result of the previous operation
//@@ next binder may receive an error if previous operation fails and the binder gets called
typedef JFFAsyncOperation (^JFFAsyncOperationBinder)(id result);

typedef void (^JFFDidFinishAsyncOperationHook)(id result,
                                               NSError *error,
                                               JFFDidFinishAsyncOperationHandler doneCallback);

#endif //__JASYNC__BLOCK_DEFINITIONS_H__
