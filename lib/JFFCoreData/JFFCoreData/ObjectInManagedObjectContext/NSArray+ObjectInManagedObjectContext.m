#import "NSArray+ObjectInManagedObjectContext.h"

#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSArray (ObjectInManagedObjectContext)

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
    NSArray *toObtain = [self select:^BOOL(NSManagedObject *object) {
        return object.objectID.isTemporaryID;
    }];
    
    if ([toObtain count] == 0)
        return YES;
    
    NSManagedObjectContext *context = [toObtain[0] managedObjectContext];
    return [context obtainPermanentIDsForObjects:toObtain error:outError];
}

@end
