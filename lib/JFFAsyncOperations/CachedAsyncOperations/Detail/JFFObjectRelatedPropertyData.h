#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface JFFObjectRelatedPropertyData : NSObject

@property (nonatomic) NSMutableArray *delegates;
@property (nonatomic, copy) JFFAsyncOperation asyncLoader;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback didFinishBlock;
@property (nonatomic, copy) JFFAsyncOperationHandler loaderHandler;

@end
