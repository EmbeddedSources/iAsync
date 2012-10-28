#import "NSOrderedSet+ObjectInManagedObjectContext.h"

#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSOrderedSet (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self map:^id(NSManagedObject *object) {
        return [object objectInManagedObjectContext:context];
    }];
}

@end
