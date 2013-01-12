#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface JFFCoreDataProvider : NSObject

- (NSManagedObjectContext *)contextForMainThread;
- (NSManagedObjectContext *)newPrivateQueueConcurrentContext;
- (NSManagedObjectContext *)mediateRootContext;

- (void)resetMainThreadContext;

+ (id)sharedCoreDataProvider;

- (void)saveRootContext;

- (BOOL)removeDatabaseFile:(NSError **)outError;

@end
