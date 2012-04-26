#ifndef __JASYNC__BLOCK_DEFINITIONS_H__
#define __JASYNC__BLOCK_DEFINITIONS_H__

#import <Foundation/Foundation.h>

@class NSError;

typedef void (^JFFAsyncOperationProgressHandler)( id progressInfo_ );

//Synchronous block which can take a lot of time
typedef id (^JFFSyncOperation)( NSError** error_ );

//This block should call progress_callback_ block only from own thread
typedef id (^JFFSyncOperationWithProgress)( NSError** error_
                                           , JFFAsyncOperationProgressHandler progressCallback_ );

typedef void (^JFFDidFinishAsyncOperationHandler)( id result_, NSError* error_ );

typedef void (^JFFCancelAsyncOperation)( BOOL unsubscribeOnlyIfNo_ );

typedef JFFCancelAsyncOperation JFFCancelAsyncOperationHandler;

//@@ progress_callback_ -- nil | valid block
//@@ cancel_callback_   -- nil | valid block
//@@ done_callback_     -- nil | valid block
typedef JFFCancelAsyncOperation (^JFFAsyncOperation)( JFFAsyncOperationProgressHandler progressCallback_
                                                     , JFFCancelAsyncOperationHandler cancelCallback_
                                                     , JFFDidFinishAsyncOperationHandler doneCallback_ );

typedef JFFAsyncOperation (^JFFAsyncOperationBinder)( id result_ );

typedef void (^JFFDidFinishAsyncOperationHook)( id result_
                                               , NSError* error_
                                               , JFFDidFinishAsyncOperationHandler doneCallback_ );

#endif //__JASYNC__BLOCK_DEFINITIONS_H__
