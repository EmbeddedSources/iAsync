#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;

@interface JFFPropertyExtractor : NSObject

@property ( nonatomic, strong ) JFFPropertyPath* propertyPath;
@property ( nonatomic, strong ) NSObject* object;

//object related data
@property ( nonatomic, strong ) NSMutableArray* delegates;
@property ( nonatomic, copy ) JFFCancelAsyncOperation cancelBlock;
@property ( nonatomic, copy ) JFFAsyncOperation asyncLoader;
@property ( nonatomic, copy ) JFFDidFinishAsyncOperationHandler didFinishBlock;

@property ( nonatomic, strong ) id property;

-(void)clearData;

@end
