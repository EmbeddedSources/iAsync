#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@protocol JFFObjectInManagedObjectContextProtocol <NSObject>

@required
- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context;

@end
