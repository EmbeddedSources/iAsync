#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFAsyncOperationProgressBlockHolder : NSObject

@property (nonatomic, copy) JFFAsyncOperationProgressCallback progressBlock;

- (void)performProgressBlockWithArgument:(id)progressInfo;

@end
