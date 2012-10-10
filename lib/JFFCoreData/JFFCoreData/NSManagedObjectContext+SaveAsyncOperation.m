#import "NSManagedObjectContext+SaveAsyncOperation.h"

#import "JFFCoreDataAsyncOperationAdapter.h"

#import "NSArray+ObjectInManagedObjectContext.h"

@implementation NSManagedObjectContext (SaveAsyncOperation)

- (JFFAsyncOperation)saveOperationLoader
{
    //TODO mm2
    JFFCoreDataSyncOperation block = ^id<JFFObjectInManagedObjectContextProtocol>(NSManagedObjectContext *context,
                                                                                  NSError **outError) {
        
        BOOL saved = [self save:outError];
        
        if ([self.undoManager groupingLevel] > 0) {
            [self.undoManager endUndoGrouping];
            [self processPendingChanges];
        }
        
        return saved?@[]:nil;
    };
    return [JFFCoreDataAsyncOperationAdapter operationWithBlock:block];
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
