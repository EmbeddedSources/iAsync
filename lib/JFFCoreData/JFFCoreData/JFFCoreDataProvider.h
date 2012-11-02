#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface JFFCoreDataProvider : NSObject

- (NSManagedObjectContext *)contextForCurrentThread;

+ (id)sharedCoreDataProvider;

- (void)saveRootContext;

@end
