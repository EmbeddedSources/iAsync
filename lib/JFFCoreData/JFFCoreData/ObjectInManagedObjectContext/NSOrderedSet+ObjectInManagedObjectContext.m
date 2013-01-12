#import "NSOrderedSet+ObjectInManagedObjectContext.h"

#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSOrderedSet (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self map:^id(NSManagedObject *object) {
        return [object objectInManagedObjectContext:context];
    }];
}

- (void)updateManagedObjectFromContext
{
    [self enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
        [obj updateManagedObjectFromContext];
    }];
}

- (BOOL)obtainPermanentIDsIfNeedsWithError:(NSError **)outError
{
    NSOrderedSet *toObtain = [self select:^BOOL(NSManagedObject *object) {
        return object.objectID.isTemporaryID;
    }];
    
    if ([toObtain count] == 0)
        return YES;
    
    NSManagedObjectContext *context = [toObtain[0] managedObjectContext];
    return [context obtainPermanentIDsForObjects:[toObtain array] error:outError];
}

@end
