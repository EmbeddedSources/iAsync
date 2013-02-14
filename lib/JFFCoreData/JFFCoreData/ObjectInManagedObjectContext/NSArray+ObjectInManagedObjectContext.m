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

- (NSManagedObject *)managedObjectForObject
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)obtainPermanentIDsIfNeedsWithError:(NSError **)outError
{
    NSArray *managedObjects = [self map:^id(id object) {
        
        return [object managedObjectForObject];
    }];
    
    NSArray *toObtain = [managedObjects select:^BOOL(NSManagedObject *object) {
        return [object.objectID isTemporaryID];
    }];
    
    if ([toObtain count] == 0)
        return YES;
    
    NSManagedObjectContext *context = [toObtain[0] managedObjectContext];
    return [context obtainPermanentIDsForObjects:toObtain error:outError];
}

@end
