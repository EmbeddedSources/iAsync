#import "JFFDBManager.h"

#import "JFFCaches.h"

#import "JFFDBInfo.h"
#import "JFFCacheDB.h"

@implementation JFFDBManager

- (void)migrateDB
{
    NSDictionary *cacheDbByName = [[JFFCaches sharedCaches]cacheDbByName];
    [cacheDbByName enumerateKeysAndObjectsUsingBlock:^(id key, id< JFFCacheDB > db, BOOL *stop) {
        [db migrateDB];
    }];
    
    [[JFFDBInfo sharedDBInfo]setCurrentDbInfo:[[JFFDBInfo sharedDBInfo]dbInfo]];
}

- (void)synchronizeDB
{
    [self migrateDB];
}

@end
