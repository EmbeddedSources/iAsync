#import "JFFDBManager.h"

#import "JFFCaches.h"

#import "JFFDBInfo.h"
#import "JFFCacheDB.h"

@implementation JFFDBManager

-(void)migrateDB
{
    NSDictionary* cacheDbByName_ = [ [ JFFCaches sharedCaches ] cacheDbByName ];
    [ cacheDbByName_ enumerateKeysAndObjectsUsingBlock: ^( id key, id< JFFCacheDB > db_, BOOL* stop_ )
    {
        [ db_ migrateDB ];
    } ];

    [ [ JFFDBInfo sharedDBInfo ] setCurrentDbInfo: [ [ JFFDBInfo sharedDBInfo ] dbInfo ] ];
}

-(void)synchronizeDB
{
    [ self migrateDB ];
}

@end
