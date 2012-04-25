#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

//JTODO remove this class
@interface JFFCancelAsyncOperationBlockHolder : NSObject

@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;
@property ( nonatomic, copy, readonly ) JFFCancelAsyncOperation onceCancelBlock;

@end
