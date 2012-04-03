#import "JFFDBManager.h"

#import "JFFCaches.h"

#import "JFFDBInfo.h"

@implementation JFFDBManager

+(id)manager
{
    return [ self new ];
}

-(void)migrateDB
{
    NSArray* databases_ = [ [ [ JFFCaches sharedCaches ] cacheDbByName ] allValues ];
    [ databases_ makeObjectsPerformSelector: @selector( migrateDB ) ];

    [ [ JFFDBInfo sharedDBInfo ] setCurrentDbInfo: [ [ JFFDBInfo sharedDBInfo ] dbInfo ] ];
}

-(void)synchronizeDB
{
    [ self migrateDB ];
}

@end
