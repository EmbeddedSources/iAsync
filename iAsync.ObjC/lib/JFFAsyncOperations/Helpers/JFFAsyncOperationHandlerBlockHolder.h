#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFAsyncOperationHandlerBlockHolder : NSObject

@property (nonatomic, copy) JFFAsyncOperationHandler loaderHandler;
@property (nonatomic, copy, readonly) JFFAsyncOperationHandler smartLoaderHandler;

- (void)performCancelBlockOnceWithArgument:(JFFAsyncOperationHandlerTask)task;
- (void)performHandlerWithArgument:(JFFAsyncOperationHandlerTask)task;

@end
