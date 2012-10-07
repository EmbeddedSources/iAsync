#import "JFFCoreDataProvider.h"

#import "NSManagedObjectContext+SaveAsyncOperation.h"

#define MINIMUM_NUMBER_OF_CHANGES_FOR_SAVING 5

@interface JFFCoreDataProvider ()

@property (nonatomic) NSManagedObjectContext *contextForSavingInStore;
@property (nonatomic) NSManagedObjectContext *mediateRootContext;

@property (readonly) NSManagedObjectModel *managedObjectModel;
@property (readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation JFFCoreDataProvider
{
    NSManagedObjectContext *_contextForMainThread;
}

+ (id)sharedCoreDataProvider
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

@synthesize managedObjectModel         = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSManagedObjectContext *)contextForCurrentThread
{
    if ([NSThread isMainThread]) {
        return [self contextForMainThread];
    }
    
    //TODO create it once for thread
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    managedObjectContext.parentContext = self.mediateRootContext;
    return managedObjectContext;
}

- (NSManagedObjectContext *)contextForMainThread
{
    if (_contextForMainThread != nil)
        return _contextForMainThread;
    
    _contextForMainThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _contextForMainThread.parentContext = self.mediateRootContext;
    
    NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
    [_contextForMainThread setMergePolicy:mergePolicy];
    
    _contextForMainThread.undoManager = [NSUndoManager new];
    [_contextForMainThread.undoManager disableUndoRegistration];
    
    return _contextForMainThread;
}

+ (NSManagedObjectModel *)newManagedObjectModelNamed:(NSString *)modelFileName
{
	NSString *path = [[NSBundle mainBundle] pathForResource:[modelFileName stringByDeletingPathExtension]
                                                     ofType:[modelFileName pathExtension]];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	
	NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	return model;
}

+ (NSManagedObjectModel *)managedObjectModelNamed:(NSString *)modelFileName
{
	return [self newManagedObjectModelNamed:modelFileName];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
        return _managedObjectModel;
    
    _managedObjectModel = [[self class] managedObjectModelNamed:@"Wishdates.momd"];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)newPersistentStoreCoordinator
{
    NSURL *documentsStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wishdates.sqlite"];
    NSError *error = nil;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:documentsStoreURL
                                                        options:nil
                                                          error: &error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        if (error.domain == NSCocoaErrorDomain) {
            NSLog(@"Old store found");
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if ([fileManager removeItemAtURL:documentsStoreURL error:&error]) {
                if ([persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                             configuration:nil
                                                                       URL:documentsStoreURL
                                                                   options:nil
                                                                     error:&error]) {
                    NSLog(@" created new _persistentStoreCoordinator");
                } else {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            } else {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        else
            abort();
    }
    
    return persistentStoreCoordinator;
    
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
        return _persistentStoreCoordinator;
    
    @synchronized(self) {
        if (_persistentStoreCoordinator)
            return _persistentStoreCoordinator;
        
        _persistentStoreCoordinator = [self newPersistentStoreCoordinator];
        
        return _persistentStoreCoordinator;
    }
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory  //  returns the URL to the application's Documents directory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

#pragma mark - Mediate context

- (NSManagedObjectContext *)mediateRootContext
{
    if (!_mediateRootContext) {
        _mediateRootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _mediateRootContext.parentContext = self.contextForSavingInStore;
        NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        _mediateRootContext.mergePolicy = mergePolicy;
    }
    return _mediateRootContext;
}

- (void)saveMediationContext
{
    [self.mediateRootContext performBlock: ^{
        NSError *error = nil;
        [self.mediateRootContext save:&error];
        
        [self saveRootContextIfNeed];
        
        if (error) {
            NSLog(@"Error during saving root context: %@", error);
        }
    }];
}

#pragma mark - Context for saving

//- (NSManagedObjectContext *)

- (NSManagedObjectContext *)contextForSavingInStore
{
    if (self->_contextForSavingInStore != nil)
        return self->_contextForSavingInStore;
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        self->_contextForSavingInStore = [[NSManagedObjectContext alloc] initWithConcurrencyType:(NSPrivateQueueConcurrencyType)];
        [self->_contextForSavingInStore setPersistentStoreCoordinator: coordinator];
        
        NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        [self->_contextForSavingInStore setMergePolicy:mergePolicy];
        
        //        self.saveRootContextTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(saveRootContextIfNeed) userInfo:nil repeats:YES];
    }
    
    return self->_contextForSavingInStore;
}

- (void)saveRootContextIfNeed
{
    if ([self.contextForSavingInStore hasChanges]
        && [self.contextForSavingInStore numberOfUnsavedChanges] > MINIMUM_NUMBER_OF_CHANGES_FOR_SAVING) {
        [self saveRootContext];
    }
}

- (void)saveRootContext
{
    [self.contextForSavingInStore performBlock:^ {
        NSError *error = nil;
        [self.contextForSavingInStore save:&error];
        if (error) {
            NSLog(@"Error during saving root context: %@", error);
        }
    }];
}

@end
