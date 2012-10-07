#import "NSArray+ObjectInManagedObjectContext.h"

#import "NSManagedObject+JFFCoreDataAsyncOperationAdapter.h"

@implementation NSArray (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self map:^id(NSManagedObject *object) {
        return [object objectInManagedObjectContext:context];
    }];
}

@end
