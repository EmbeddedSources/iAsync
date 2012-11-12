#import "NSManagedObject+UpdateManagedObjectFromContext.h"

@implementation NSManagedObject (UpdateManagedObjectFromContext)

- (void)updateManagedObjectFromContext
{
    [self.managedObjectContext refreshObject:self mergeChanges:NO];
}

@end
