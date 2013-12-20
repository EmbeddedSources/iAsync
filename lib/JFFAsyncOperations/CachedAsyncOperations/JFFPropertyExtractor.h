#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;

@interface JFFPropertyExtractor : NSObject

// Do not pass properties with primitive types (int/BOOL/...)
@property ( nonatomic ) JFFPropertyPath* propertyPath;
@property ( nonatomic ) NSObject* object;

//object related data
@property (nonatomic) NSMutableArray *delegates;
@property (nonatomic, copy) JFFCancelAsyncOperation cancelBlock;
@property (nonatomic, copy) JFFAsyncOperation asyncLoader;
@property (nonatomic, copy) JFFDidFinishAsyncOperationHandler didFinishBlock;

@property (nonatomic) id property;

- (void)clearData;

@end
