#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFObjectRelatedPropertyData : NSObject

@property ( nonatomic, strong ) NSMutableArray* delegates;
@property ( nonatomic, copy ) JFFAsyncOperation asyncLoader;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;
@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;

@end
