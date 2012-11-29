#import "NSManagedObject+JSONParser.h"

#import "JFFCoreDataProvider.h"

@implementation NSManagedObject (JSONParser)

+ (NSArray *)cachedManagedObjectsInContext:(NSManagedObjectContext *)context
                                 arrayData:(NSArray *)arrayData
                               primaryKeys:(JFFCoreDataCachePrimaryKeys)primaryKeysBlock
{
    if (!primaryKeysBlock)
        return nil;
    
    NSArray *primaryKeyAndValues = primaryKeysBlock(arrayData);
    NSParameterAssert([primaryKeyAndValues count] == 2);
    
    NSString *modelKey        = primaryKeyAndValues[0];
    NSArray *primaryKeyValues = primaryKeyAndValues[1];
    
    NSParameterAssert([primaryKeyValues count] == [arrayData count]);
    
    //TODO fix hardcode ProfileModel
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([self class])];
    request.predicate = [NSPredicate predicateWithFormat:@"%K IN (%@)", modelKey, primaryKeyValues];
    request.includesPendingChanges = YES;
    request.fetchLimit = [arrayData count];
    
    NSError *error;
    NSArray *cachedObjects = [context executeFetchRequest:request error:&error];
    
    NSParameterAssert(!error);
    NSParameterAssert(cachedObjects);
    
    NSMutableDictionary *objectByKeys = [NSMutableDictionary new];
    for (NSManagedObject *mnObject in cachedObjects) {
        
        id key = [mnObject valueForKey:modelKey];
        NSParameterAssert(key);
        objectByKeys[key] = mnObject;
    }
    
    return @[cachedObjects, primaryKeyValues, [objectByKeys copy]];
}

//TODO move to public
+ (id)createManagedObjectInContext:(NSManagedObjectContext *)context
{
	NSString *entityName = NSStringFromClass([self class]);
	return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
}

+ (NSArray *)managedObjectsInContext:(NSManagedObjectContext *)context
                           arrayData:(NSArray *)arrayData
                         primaryKeys:(JFFCoreDataCachePrimaryKeys)primaryKeys
                              parser:(JFFCoreDataModelParser)parser
                               error:(NSError *__autoreleasing *)outError
{
    NSParameterAssert(parser);
    NSParameterAssert([arrayData isKindOfClass:[NSArray class]]);
    
    context = context?:[[JFFCoreDataProvider sharedCoreDataProvider] contextForCurrentThread];
    
    static NSTimeInterval timeInterval = 0.;
    NSDate *startDate = [NSDate new];
    
    NSArray *cachedObjectsResult = [self cachedManagedObjectsInContext:context
                                                             arrayData:arrayData
                                                           primaryKeys:primaryKeys];
    
    NSArray *cachedObjects    ;
    NSArray *primaryKeyValues ;
    NSDictionary *objectByKeys;
    if (cachedObjectsResult) {
        cachedObjects    = cachedObjectsResult[0];
        primaryKeyValues = cachedObjectsResult[1];
        objectByKeys     = cachedObjectsResult[2];
    }
    
    timeInterval += [[NSDate new] timeIntervalSinceDate:startDate];
    NSLog(@"fetch time: %f", timeInterval);
    
    static NSTimeInterval timeInterval2 = 0.;
    NSDate *startDate2 = [NSDate new];
    
    NSArray *objects = [arrayData mapWithIndex:^id(NSDictionary *jsonObject,
                                                   NSInteger idx,
                                                   NSError *__autoreleasing *outError) {
        
        NSManagedObject *cachedObject;
        if (cachedObjectsResult) {
            cachedObject = objectByKeys[primaryKeyValues[idx]];
        }
        
        cachedObject = cachedObject?:[self createManagedObjectInContext:context];
        NSManagedObject *model = parser(jsonObject, cachedObject, outError);

        [context save:outError];
        
        return model;
    } error:outError];
    
    timeInterval2 += [[NSDate new] timeIntervalSinceDate:startDate2];
    NSLog(@"parse ar time: %f", timeInterval2);
    
    if (!objects)
        return nil;
    
    BOOL result = YES;//[context save:outError];
    
    return result?objects:nil;
}

@end
