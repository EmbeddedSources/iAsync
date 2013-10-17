#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCallbacksBlocksHolder : NSObject

@property (nonatomic, copy) JFFAsyncOperationProgressHandler onProgressBlock;
@property (nonatomic, copy) JFFCancelAsyncOperationHandler onCancelBlock;
@property (nonatomic, copy) JFFDidFinishAsyncOperationHandler didLoadDataBlock;

- (instancetype)initWithOnProgressBlock:(JFFAsyncOperationProgressHandler)onProgressBlock
                          onCancelBlock:(JFFCancelAsyncOperationHandler)onCancelBlock
                       didLoadDataBlock:(JFFDidFinishAsyncOperationHandler)didLoadDataBlock;

@end
