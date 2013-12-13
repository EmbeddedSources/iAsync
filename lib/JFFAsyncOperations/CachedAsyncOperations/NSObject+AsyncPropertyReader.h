#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class
JFFPropertyPath,
JFFPropertyExtractor;

typedef JFFPropertyExtractor *(^JFFPropertyExtractorFactoryBlock)(void);

@interface NSObject (AsyncPropertyReader)

//TODO20 test immediately cancel
//TODO20 test cancel calback for each observer
- (JFFAsyncOperation)asyncOperationForPropertyWithName:(NSString *)propertyName
                                        asyncOperation:(JFFAsyncOperation)asyncOperation;

- (JFFAsyncOperation)asyncOperationForPropertyWithName:(NSString *)propertyName
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation;

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                                        asyncOperation:(JFFAsyncOperation)asyncOperation;

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation;

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                         propertyExtractorFactoryBlock:(JFFPropertyExtractorFactoryBlock)factory
                                        asyncOperation:(JFFAsyncOperation)asyncOperation;

- (JFFAsyncOperation)asyncOperationForPropertyWithPath:(JFFPropertyPath *)propertyPath
                         propertyExtractorFactoryBlock:(JFFPropertyExtractorFactoryBlock)factory
                                        asyncOperation:(JFFAsyncOperation)asyncOperation
                                didFinishLoadDataBlock:(JFFDidFinishAsyncOperationCallback)didFinishOperation;

- (JFFAsyncOperation)asyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
                                   withArgument:(id< NSCopying, NSObject >)argument;

- (BOOL)isLoadingPropertyForPropertyName:(NSString *)name;

+ (JFFAsyncOperation)asyncOperationMergeLoaders:(JFFAsyncOperation)asyncOperation
                                   withArgument:(id< NSCopying, NSObject >)argument;

@end
