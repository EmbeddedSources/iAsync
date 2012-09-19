#import "JFFCaches.h"

#import "JFFCacheDB.h"
#import "JFFBaseDB.h"
#import "JFFDBInfo.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>
#import <JFFScheduler/JFFScheduler.h>

static JFFCaches* sharedCachesInstance= nil;

@interface JFFInternalCacheDB : JFFBaseDB

@property ( nonatomic ) NSString* configPropertyName;

@end

@implementation JFFInternalCacheDB

- (void)configureCachesWithCacheDBWithName:(NSString *)dbPropertyName
                                    dbInfo:(JFFDBInfo *)dbInfo
{
    self->_configPropertyName = dbPropertyName;
    
    NSDictionary *dbInfoDict = [dbInfo dbInfo];
    NSTimeInterval removeRarelyAccessDataDelay =
        [ dbInfoDict autoRemoveByLastAccessDateForDBWithName: self->_configPropertyName ];
    if ( removeRarelyAccessDataDelay != 0 )
    {
        __weak JFFInternalCacheDB* self_ = self;
        JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ )
        {
            NSDate* fromDate_ = [[NSDate new]dateByAddingTimeInterval:-removeRarelyAccessDataDelay];
            [ self_ removeRecordsToAccessDate: fromDate_ ];
        };
        block_( nil );
        JFFScheduler* scheduler_ = [ JFFScheduler sharedByThreadScheduler ];
        [ self addOnDeallocBlock: [ scheduler_ addBlock: block_ duration: 3600. ] ];
    }
}

-(id)initWithCacheDBWithName:( NSString* )dbPropertyName_
                      dbInfo:( JFFDBInfo* )dbInfo_
{
    NSString* dbName_ = [ dbInfo_.dbInfo fileNameForDBWithName: dbPropertyName_ ];
    
    self = [ super initWithDBName: dbName_ cacheName: dbPropertyName_ ];
    
    if ( self )
    {
        [ self configureCachesWithCacheDBWithName: dbPropertyName_
                                           dbInfo: dbInfo_ ];
    }

    return self;
}

+(id)internalCacheDBWithName:( NSString* )dbPropertyName_
                      dbInfo:( JFFDBInfo* )dbInfo_
{
    return [ [ self alloc ] initWithCacheDBWithName: dbPropertyName_
                                             dbInfo: dbInfo_ ];
}

-(void)migrateDB
{
    NSDictionary *currentDbInfo = [[JFFDBInfo sharedDBInfo] currentDbInfo];
    if (!currentDbInfo)
    {
        return;
    }
    
    NSDictionary *dbInfo = [[JFFDBInfo sharedDBInfo] dbInfo];
    
    NSInteger lastVersion = [dbInfo versionForDBWithName:self->_configPropertyName];
    NSInteger currentVersion = [currentDbInfo versionForDBWithName:self->_configPropertyName];
    
    if (lastVersion > currentVersion)
    {
        [self removeAllRecords];
    }
}

- (NSNumber*)timeToLiveInHours
{
    NSDictionary *dbInfo = [[JFFDBInfo sharedDBInfo] dbInfo];
    NSNumber *result = [dbInfo timeToLiveInHoursForDBWithName:self->_configPropertyName];
    return result;
}

@end

@interface JFFCaches ()

@property ( nonatomic, readonly ) NSMutableDictionary* mutableCacheDbByName;

@end

@implementation JFFCaches
{
    NSMutableDictionary* _mutableCacheDbByName;
}

- (id< JFFCacheDB >)registerAndCreateCacheDBWithName:(NSString *)dbPropertyName
                                              dbInfo:(JFFDBInfo *)dbInfo
{
    id< JFFCacheDB > result = self.mutableCacheDbByName[dbPropertyName];
    
    if (!result)
    {
        result = [JFFInternalCacheDB internalCacheDBWithName:dbPropertyName
                                                      dbInfo:dbInfo];
        self.mutableCacheDbByName[dbPropertyName] = result;
    }
    
    return result;
}

- (void)setupCachesWithDBInfo:(JFFDBInfo *)dbInfo
{
    [dbInfo.dbInfo enumerateKeysAndObjectsUsingBlock:^(id dbName, id obj, BOOL *stop)
    {
        [self registerAndCreateCacheDBWithName:dbName
                                        dbInfo:dbInfo];
    } ];
}

- (id)initWithDBInfoDictionary:(NSDictionary *)cachesInfo
{
    JFFDBInfo *dbInfo = [[JFFDBInfo alloc]initWithInfoDictionary:cachesInfo];
    return [self initWithDBInfo:dbInfo];
}

- (id)initWithDBInfo:(JFFDBInfo *)dbInfo
{
    self = [ super init ];
    
    if (self)
    {
        [self setupCachesWithDBInfo:dbInfo];
    }
    
    return self;
}

+ (JFFCaches *)sharedCaches
{
    if (!sharedCachesInstance)
    {
        JFFDBInfo *dbInfo = [JFFDBInfo sharedDBInfo];
        sharedCachesInstance = [[self alloc]initWithDBInfo:dbInfo];
    }
    
    return sharedCachesInstance;
}

+ (void)setSharedCaches:(JFFCaches *)caches
{
    sharedCachesInstance = caches;
}

- (NSMutableDictionary *)mutableCacheDbByName
{
    if ( !self->_mutableCacheDbByName )
    {
        self->_mutableCacheDbByName = [NSMutableDictionary new];
    }
    
    return self->_mutableCacheDbByName;
}

- (NSDictionary *)cacheDbByName
{
    return self.mutableCacheDbByName;
}

- (id< JFFCacheDB >)cacheByName:(NSString *)name
{
    return self.cacheDbByName[name];
}

- (id< JFFCacheDB >)thumbnailDB
{
    return [self cacheByName:@"JFF_THUMBNAIL_DB"];
}

@end
