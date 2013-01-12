#ifndef JFFCoreData_JFFCoreDataAsyncBlocks_h
#define JFFCoreData_JFFCoreDataAsyncBlocks_h

@class NSError;
@class NSManagedObjectContext;

@protocol JFFObjectInManagedObjectContext;

typedef id<JFFObjectInManagedObjectContext> (^JFFCoreDataSyncOperation)(NSError *__autoreleasing *outError);

typedef id<JFFObjectInManagedObjectContext> (^JFFCoreDataSyncOperationWithObject)(id managedObject, NSError *__autoreleasing *outError);

typedef JFFCoreDataSyncOperation (^JFFCoreDataSyncOperationFactory)(NSManagedObjectContext *context);
typedef JFFCoreDataSyncOperationWithObject (^JFFCoreDataSyncOperationWithObjectFactory)(NSManagedObjectContext *context);

#endif
