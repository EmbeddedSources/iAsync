#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSManagedObject (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [context objectWithID:self.objectID];
}

@end
