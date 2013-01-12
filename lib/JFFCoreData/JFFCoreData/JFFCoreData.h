
#import <JFFCoreData/JFFCoreDataProvider.h>
#import <JFFCoreData/JFFCoreDataAsyncOperationAdapter.h>

#import <JFFCoreData/Extensions/NSManagedObject+SaveAsyncOperation.h>

#import <JFFCoreData/ObjectInManagedObjectContext/NSArray+ObjectInManagedObjectContext.h>
#import <JFFCoreData/ObjectInManagedObjectContext/NSDictionary+ObjectInManagedObjectContext.h>
#import <JFFCoreData/ObjectInManagedObjectContext/NSOrderedSet+ObjectInManagedObjectContext.h>
#import <JFFCoreData/ObjectInManagedObjectContext/NSManagedObject+ObjectInManagedObjectContext.h>

#import <JFFCoreData/JSONParser/NSManagedObject+JSONParser.h>

#include <JFFCoreData/AsyncCoreData/JFFCDReadWriteLock.h>
#include <JFFCoreData/AsyncCoreData/JFFCoreDataAsyncBlocks.h>

#import <JFFCoreData/Errors/JFFNoManagedObjectError.h>
