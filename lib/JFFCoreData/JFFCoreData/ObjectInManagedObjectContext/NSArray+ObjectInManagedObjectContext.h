#import <Foundation/Foundation.h>

@interface NSArray (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context;

@end
