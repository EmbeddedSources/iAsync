#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@protocol JFFObjectInManagedObjectContextProtocol;

typedef id<JFFObjectInManagedObjectContextProtocol> (^JFFCoreDataSyncOperation)(NSManagedObjectContext *context,
                                                                                NSError *__autoreleasing *outError);

@interface JFFCoreDataAsyncOperationAdapter : NSObject

+ (JFFAsyncOperation)operationWithBlock:(JFFCoreDataSyncOperation)block;

@end
