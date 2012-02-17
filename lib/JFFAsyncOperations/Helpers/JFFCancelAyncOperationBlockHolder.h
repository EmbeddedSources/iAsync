#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFCancelAyncOperationBlockHolder : NSObject

@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;
@property ( nonatomic, copy, readonly ) JFFCancelAsyncOperation onceCancelBlock;

@end
