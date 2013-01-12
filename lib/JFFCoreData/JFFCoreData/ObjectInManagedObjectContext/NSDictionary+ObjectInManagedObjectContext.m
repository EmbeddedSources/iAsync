#import "NSDictionary+ObjectInManagedObjectContext.h"

#import "NSManagedObject+ObjectInManagedObjectContext.h"

@implementation NSDictionary (ObjectInManagedObjectContext)

- (id)objectInManagedObjectContext:(NSManagedObjectContext *)context
{
    return [self map:^id(id key, NSManagedObject *object) {
        return [object objectInManagedObjectContext:context];
    }];
}

- (void)updateManagedObjectFromContext
{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, NSManagedObject *obj, BOOL *stop) {
        [obj updateManagedObjectFromContext];
    }];
}

- (BOOL)obtainPermanentIDsIfNeedsWithError:(NSError **)outError
{
    NSDictionary *toObtainDict = [self select:^BOOL(id key, NSManagedObject *object) {
        return object.objectID.isTemporaryID;
    }];
    
    if ([toObtainDict count] == 0)
        return YES;
    
    NSArray *toObtain = [toObtainDict allValues];
    
    NSManagedObjectContext *context = [toObtain[0] managedObjectContext];
    return [context obtainPermanentIDsForObjects:toObtain error:outError];
}

@end
