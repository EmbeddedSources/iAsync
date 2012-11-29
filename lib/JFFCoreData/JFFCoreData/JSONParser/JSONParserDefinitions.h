#ifndef JFFCoreData_JSONParserDefinitions_h
#define JFFCoreData_JSONParserDefinitions_h

@class NSArray;
@class NSManagedObject;

//this block should return object like @[key, values]
typedef NSArray*(^JFFCoreDataCachePrimaryKeys)(NSArray *jsonObject);

typedef NSManagedObject*(^JFFCoreDataModelParser)(id jsonObject,
                                                  NSManagedObject* cachedObject,
                                                  NSError **outError);

#endif
