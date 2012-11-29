#import "JFFCoreDataProvider.h"

#import "NSManagedObjectContext+SaveAsyncOperation.h"

@interface JFFCoreDataProvider ()

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
    
    return [self contextForBackgroundThread];
}

- (NSManagedObjectContext *)contextForBackgroundThread
{
    //TODO create it once for thread
    NSManagedObjectContext *contextForCurrentThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    contextForCurrentThread.parentContext = self.mediateRootContext;
    return contextForCurrentThread;
}

- (NSManagedObjectContext *)contextForMainThread
{
    if (_contextForMainThread != nil)
        return _contextForMainThread;
    
    _contextForMainThread = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _contextForMainThread.parentContext = self.mediateRootContext;
    
    NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
    [_contextForMainThread setMergePolicy:mergePolicy];
    
    _contextForMainThread.undoManager = [NSUndoManager new];
    [_contextForMainThread.undoManager disableUndoRegistration];
    
    return _contextForMainThread;
}

- (void)resetMainThreadContext
{
    _contextForMainThread = nil;
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
    NSURL *documentsStoreURL = [self dataBaseFileURL];
    NSError *error;
    
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

- (NSURL *)dataBaseFileURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Wishdates.sqlite"];
}

- (BOOL)removeDatabaseFile:(NSError **)outError
{
    NSURL *dbUrl = [self dataBaseFileURL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL result = YES;
    if ([fileManager fileExistsAtPath:dbUrl.path]) {
        result = [fileManager removeItemAtURL:dbUrl error:outError];
    }
    
    _contextForMainThread = nil;
    _mediateRootContext = nil;
    _persistentStoreCoordinator = nil;
    
    return result;
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
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                           inDomains:NSUserDomainMask];
    return [urls lastObject];
}

#pragma mark - Mediate context

- (NSManagedObjectContext *)mediateRootContext
{
    if (_mediateRootContext)
        return _mediateRootContext;
    
    @synchronized(self) {
        
        if (_mediateRootContext)
            return _mediateRootContext;
        
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        
        _mediateRootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:(NSPrivateQueueConcurrencyType)];
        [_mediateRootContext setPersistentStoreCoordinator: coordinator];
        
        NSMergePolicy *mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
        [_mediateRootContext setMergePolicy:mergePolicy];
    }
    
    return _mediateRootContext;
}

- (void)saveRootContext
{
    [self.mediateRootContext performBlock: ^{
        NSError *error = nil;
        [self.mediateRootContext save:&error];
        
        if (error) {
            NSLog(@"Error during saving root context: %@", error);
        }
    }];
}

@end
