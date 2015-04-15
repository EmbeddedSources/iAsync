//
//  JAsyncOperationsDefinitions.h
//  JAsyncOperations
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

#ifndef JAsyncOperations_JAsyncOperationsDefinitions_h
#define JAsyncOperations_JAsyncOperationsDefinitions_h

#import <JUtils/JUtils-Swift.h>
#import <JAsync/JAsync-Swift.h>

typedef void (^JFFAsyncOperationProgressCallback)(id progressInfo);

//Synchronous block which can take a lot of time
typedef id (^JFFSyncOperation)(NSError *__autoreleasing *outError);

//This block should call progress_callback_ block only from own thread
typedef id (^JFFSyncOperationWithProgress)(NSError *__autoreleasing *error,
                                           JFFAsyncOperationProgressCallback progressCallback);

typedef void (^JFFDidFinishAsyncOperationCallback)(id result, NSError *error);

typedef void (^JFFAsyncOperationHandler)(JAsyncHandlerTask task);

typedef void (^JFFAsyncOperationChangeStateCallback)(JAsyncState state);

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

extern JFFAsyncOperationHandler JFFStubHandlerAsyncOperationBlock;

#endif
