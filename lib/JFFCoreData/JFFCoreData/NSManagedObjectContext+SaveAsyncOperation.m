#import "NSManagedObjectContext+SaveAsyncOperation.h"

#import "JFFCoreDataAsyncOperationAdapter.h"

#import "NSArray+ObjectInManagedObjectContext.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

@implementation NSManagedObjectContext (SaveAsyncOperation)

- (JFFAsyncOperation)saveOperationLoader
{
    __weak NSManagedObjectContext *__self = self;
    
    JFFSyncOperation syncChangeModel = ^id(NSError **outError) {
        
        BOOL saved = [__self save:outError];
        
        if ([__self.undoManager groupingLevel] > 0) {
            [__self.undoManager endUndoGrouping];
        }
        [__self processPendingChanges];
        
        return saved?@[]:nil;
    };
    
    return asyncOperationWithSyncOperationInCurrentQueue(syncChangeModel);
}

- (NSUInteger)numberOfUnsavedChanges
{
	NSManagedObjectContext *moc = self;
	
	NSUInteger unsavedCount = 0;
	unsavedCount += [[moc updatedObjects ] count];
	unsavedCount += [[moc insertedObjects] count];
	unsavedCount += [[moc deletedObjects ] count];
	
	return unsavedCount;
}

@end
