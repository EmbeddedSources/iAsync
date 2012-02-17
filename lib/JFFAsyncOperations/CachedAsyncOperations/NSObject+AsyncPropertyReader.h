#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class JFFPropertyPath;
@class JFFPropertyExtractor;

typedef JFFPropertyExtractor* (^JFFPropertyExtractorFactoryBlock)( void );

@interface NSObject (AsyncPropertyReader)

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )propertyName_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithName:( NSString* )propertyName_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_;

-(JFFAsyncOperation)asyncOperationForPropertyWithPath:( JFFPropertyPath* )propertyPath_
                        propertyExtractorFactoryBlock:( JFFPropertyExtractorFactoryBlock )factory_
                                       asyncOperation:( JFFAsyncOperation )asyncOperation_
                               didFinishLoadDataBlock:( JFFDidFinishAsyncOperationHandler )didFinishOperation_;

-(JFFAsyncOperation)asyncOperationMergeLoaders:( JFFAsyncOperation )asyncOperation_
                                  withArgument:( id< NSCopying, NSObject > )argument_;

-(BOOL)isLoadingPropertyForPropertyName:( NSString* )name_;

@end
