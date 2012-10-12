#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSManagedObject (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    id newObject = [context objectWithID:self.objectID];
    [context refreshObject:newObject mergeChanges:YES];
    
    return newObject;
}

@end
