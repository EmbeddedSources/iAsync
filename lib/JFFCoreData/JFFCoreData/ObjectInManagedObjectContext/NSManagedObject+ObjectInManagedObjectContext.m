#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSManagedObject (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSParameterAssert(![context isEqual:self.managedObjectContext]);
    id newObject = [context objectWithID:self.objectID];
    return newObject;
}

- (void)updateManagedObjectFromContext
{
    [self.managedObjectContext refreshObject:self mergeChanges:YES];
}

- (BOOL)obtainPermanentIDsIfNeedsWithError:(NSError **)outError
{
    if (!self.objectID.isTemporaryID)
        return YES;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    return [context obtainPermanentIDsForObjects:@[self] error:outError];
}

- (NSManagedObject *)managedObjectForObject
{
    return self;
}

@end
