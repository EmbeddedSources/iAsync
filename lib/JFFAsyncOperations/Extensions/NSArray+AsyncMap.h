#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@interface NSArray (AsyncMap)

-(JFFAsyncOperation)asyncMap:( JFFAsyncOperationBinder )block_;

-(JFFAsyncOperation)tolerantFaultAsyncMap:( JFFAsyncOperationBinder )block_;

@end
