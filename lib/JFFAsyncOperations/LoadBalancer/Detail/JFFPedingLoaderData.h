#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFPedingLoaderData : NSObject

@property ( nonatomic, copy ) JFFAsyncOperation nativeLoader;
@property ( nonatomic, copy ) JFFAsyncOperationProgressHandler progressCallback;
@property ( nonatomic, copy ) JFFCancelAsyncOperationHandler cancelCallback;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler doneCallback;

@end
