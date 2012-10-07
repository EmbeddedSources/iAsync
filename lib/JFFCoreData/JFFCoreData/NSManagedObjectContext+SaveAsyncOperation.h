#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (SaveAsyncOperation)

- (JFFAsyncOperation)saveOperationLoader;

- (NSUInteger)numberOfUnsavedChanges;


@end
