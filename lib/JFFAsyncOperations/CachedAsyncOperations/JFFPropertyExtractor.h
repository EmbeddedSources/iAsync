#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;

@interface JFFPropertyExtractor : NSObject

@property (nonatomic) JFFPropertyPath *propertyPath;
@property (nonatomic) NSObject *object;

//object related data
@property (nonatomic) NSMutableArray *delegates;
@property (nonatomic, copy) JFFAsyncOperation asyncLoader;
@property (nonatomic, copy) JFFAsyncOperationHandler loaderHandler;
@property (nonatomic, copy) JFFDidFinishAsyncOperationCallback didFinishBlock;

@property (nonatomic) id property;

- (void)clearData;

@end
