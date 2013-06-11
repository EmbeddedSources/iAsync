#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFObjectRelatedPropertyData : NSObject

@property (nonatomic) NSMutableArray *delegates;
@property (nonatomic, copy) JFFAsyncOperation asyncLoader;
@property (nonatomic, copy) JFFDidFinishAsyncOperationHandler didFinishBlock;
@property (nonatomic, copy) JFFCancelAsyncOperation cancelBlock;

@end
