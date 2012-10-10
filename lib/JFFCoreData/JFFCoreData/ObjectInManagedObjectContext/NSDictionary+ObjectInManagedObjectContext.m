#import "NSDictionary+ObjectInManagedObjectContext.h"

#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSDictionary (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self map:^id(id key, NSManagedObject *object) {
        return [object objectInManagedObjectContext:context];
    }];
}

@end
