#import "NSManagedObject+JFFCoreDataAsyncOperationAdapter.h"

@implementation NSManagedObject (JFFCoreDataAsyncOperationAdapter)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [context objectWithID:self.objectID];
}

@end
