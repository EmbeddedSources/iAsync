#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface JFFCoreDataProvider : NSObject

//TODO a lot of calls - refactor
- (NSManagedObjectContext *)contextForCurrentThread;

+ (id)sharedCoreDataProvider;

//TODO rename
- (void)saveMediationContext;

@end
