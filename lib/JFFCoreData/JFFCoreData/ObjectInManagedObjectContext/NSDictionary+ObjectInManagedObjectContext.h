#import <Foundation/Foundation.h>

@interface NSDictionary (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context;

@end
