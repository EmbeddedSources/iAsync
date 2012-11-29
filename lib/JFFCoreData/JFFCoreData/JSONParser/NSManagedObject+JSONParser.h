#include <JFFCoreData/JSONParser/JSONParserDefinitions.h>

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

@interface NSManagedObject (JSONParser)

//TODO rename to Just data parser
+ (NSArray *)managedObjectsInContext:(NSManagedObjectContext *)context
                           arrayData:(NSArray *)arrayData
                         primaryKeys:(JFFCoreDataCachePrimaryKeys)primaryKeys
                              parser:(JFFCoreDataModelParser)parser
                               error:(NSError *__autoreleasing *)outError;

@end
