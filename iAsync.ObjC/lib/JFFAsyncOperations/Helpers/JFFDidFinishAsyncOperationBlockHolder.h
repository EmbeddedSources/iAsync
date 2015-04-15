#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFDidFinishAsyncOperationBlockHolder : NSObject

@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback didFinishBlock;
@property (nonatomic, copy, readonly) JFFDidFinishAsyncOperationCallback onceDidFinishBlock;

@end
