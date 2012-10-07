#import "NSManagedObjectContext+SaveAsyncOperation.h"

#import "JFFCoreDataOperationAsyncAdapter.h"

@implementation NSManagedObjectContext (SaveAsyncOperation)

- (JFFAsyncOperation)saveOperationLoader
{
    JFFSyncOperation block = ^id(NSError *__autoreleasing *outError) {
        
        BOOL saved = [self save:outError];
        
        if ([self.undoManager groupingLevel] > 0) {
            [self.undoManager endUndoGrouping];
            [self processPendingChanges];
        }
        
        return saved?@YES:nil;
    };
    return [JFFCoreDataOperationAsyncAdapter operationWithBlock:block];
}

- (NSUInteger)numberOfUnsavedChanges
{
	NSManagedObjectContext *moc = self;
	
	NSUInteger unsavedCount = 0;
	unsavedCount += [[moc updatedObjects] count];
	unsavedCount += [[moc insertedObjects] count];
	unsavedCount += [[moc deletedObjects] count];
	
	return unsavedCount;
}

@end
