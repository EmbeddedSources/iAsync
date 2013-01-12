#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <CoreData/CoreData.h>

@interface NSManagedObject (SaveAsyncOperation)

- (JFFAsyncOperation)saveObjectLoader;

- (JFFAsyncOperation)saveObjectLoaderWithChanges:(JFFAnalyzer)changes;

@end
