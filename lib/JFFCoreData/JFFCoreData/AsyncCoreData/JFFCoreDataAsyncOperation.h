#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

#include <JFFCoreData/AsyncCoreData/JFFCDReadWriteLock.h>
#include <JFFCoreData/AsyncCoreData/JFFCoreDataAsyncBlocks.h>

@class NSManagedObject;

@protocol JFFObjectInManagedObjectContext;

@interface JFFCoreDataAsyncOperation : NSObject

+ (JFFAsyncOperation)operationWithBlock2:(JFFCoreDataSyncOperationFactory)block
                               readWrite:(JFFCDReadWriteLock)readWrite;

+ (JFFAsyncOperation)operationWithRootObject2:(NSManagedObject *)managedObject
                                       block:(JFFCoreDataSyncOperationWithObjectFactory)block
                                   readWrite:(JFFCDReadWriteLock)readWrite;

@end
