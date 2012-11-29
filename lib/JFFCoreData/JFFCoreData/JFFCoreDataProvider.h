#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface JFFCoreDataProvider : NSObject

- (NSManagedObjectContext *)contextForCurrentThread;

- (void)resetMainThreadContext;

+ (id)sharedCoreDataProvider;

- (void)saveRootContext;

- (BOOL)removeDatabaseFile:(NSError **)outError;

@end
