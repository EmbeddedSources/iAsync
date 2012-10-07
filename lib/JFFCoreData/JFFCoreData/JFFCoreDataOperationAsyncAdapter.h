#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

//TODO rename to JFFCoreDataAsyncOperationAdapter
@interface JFFCoreDataOperationAsyncAdapter : NSObject

//TODO, see each usage in project
+ (JFFAsyncOperation)operationWithBlock:(JFFSyncOperation)block;

@end
