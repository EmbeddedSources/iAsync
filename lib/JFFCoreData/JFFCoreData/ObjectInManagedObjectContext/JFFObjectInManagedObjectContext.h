#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@protocol JFFObjectInManagedObjectContext <NSObject>

@required
- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context;
- (void)updateManagedObjectFromContext;
- (BOOL)obtainPermanentIDsIfNeedsWithError:(NSError **)outError;

@end
