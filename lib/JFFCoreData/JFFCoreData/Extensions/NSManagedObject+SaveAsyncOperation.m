#import "NSManagedObject+SaveAsyncOperation.h"

#import "JFFCoreDataAsyncOperationAdapter.h"

#import "NSManagedObject+ObjectInManagedObjectContext.h"
#import "NSArray+ObjectInManagedObjectContext.h"

#import <JFFAsyncOperations/JFFAsyncOperations.h>

#import "JFFCoreDataProvider.h"

@implementation NSManagedObject (SaveAsyncOperation)

- (JFFAsyncOperation)saveObjectLoader
{
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        //TODO12 refactor this
        NSError *error;
        BOOL saved = [self.managedObjectContext save:&error];
        
        if (!saved) {
            
            [error writeErrorWithJFFLogger];
            if (doneCallback)
                doneCallback(nil, error);
            return JFFStubCancelAsyncOperationBlock;
        }
        
        __block BOOL canceledOrFinishedFlag = NO;
        
        [[[JFFCoreDataProvider sharedCoreDataProvider] mediateRootContext] performBlock:^{
            
            NSError *error;
            [[[JFFCoreDataProvider sharedCoreDataProvider] mediateRootContext] save:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!canceledOrFinishedFlag) {
                    canceledOrFinishedFlag = YES;
                    
                    //TODO weak self
                    if (doneCallback)
                        doneCallback(error?nil:self, error);
                }
            });
        }];
        
        return ^(BOOL canceled) {
            
            if (!canceledOrFinishedFlag) {
                
                canceledOrFinishedFlag = YES;
                if (cancelCallback)
                    cancelCallback(canceled);
            }
        };
    };
}

- (JFFAsyncOperation)saveObjectLoaderWithChanges:(JFFAnalyzer)changes
{
    JFFCoreDataSyncOperationWithObjectFactory block = ^JFFCoreDataSyncOperationWithObject(NSManagedObjectContext *context) {
        
        return ^id<JFFObjectInManagedObjectContext>(NSManagedObjectID *object, NSError **outError) {
            
            NSManagedObject *result = changes(object, outError);
            return result;
        };
    };
    
    return [JFFCoreDataAsyncOperationAdapter operationWithRootObject:self
                                                               block:block
                                                           readWrite:(JFFCDWriteLock)];
}

@end
