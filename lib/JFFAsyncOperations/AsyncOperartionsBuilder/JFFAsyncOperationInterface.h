#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@protocol JFFAsyncOperationInterface <NSObject>

@required
- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finnishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback;

@optional
- (void)doTask:(JFFAsyncOperationHandlerTask)task;

- (BOOL)isForeignThreadResultCallback;

@end
