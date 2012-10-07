#import <CoreData/CoreData.h>

@interface NSManagedObject (JFFCoreDataAsyncOperationAdapter)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context;

@end
