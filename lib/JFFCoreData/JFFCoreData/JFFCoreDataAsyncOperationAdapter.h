#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#include <JFFCoreData/AsyncCoreData/JFFCDReadWriteLock.h>
#include <JFFCoreData/AsyncCoreData/JFFCoreDataAsyncBlocks.h>

@class NSManagedObject;

@protocol JFFObjectInManagedObjectContext;

@interface JFFCoreDataAsyncOperationAdapter : NSObject

//TODO1 remove
+ (JFFAsyncOperation)operationWithBlock:(JFFCoreDataSyncOperationFactory)block
                              readWrite:(JFFCDReadWriteLock)readWrite;

+ (JFFAsyncOperation)operationWithRootObject:(NSManagedObject *)managedObject
                                       block:(JFFCoreDataSyncOperationWithObjectFactory)block
                                   readWrite:(JFFCDReadWriteLock)readWrite;

@end
