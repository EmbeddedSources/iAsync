#import "JFFCaches.h"

#import "JFFCacheDB.h"
#import "JFFDBInfo.h"
#import "JFFKeyValueDB.h"

#import "CacheDBInfo.h"
#import "CacheDBInfoStorage.h"

#import <JFFScheduler/JFFTimer.h>

static JFFCaches *sharedCachesInstance;

static NSMutableDictionary *autoremoveSchedulersByCacheName;
static NSString *const lockObject = @"41d318da-1229-4a50-9222-4ad870c56ecc";

@interface JFFInternalCacheDB : JFFKeyValueDB <JFFCacheDB>

@property (nonatomic) CacheDBInfo *cacheDBInfo;

@end

@implementation JFFInternalCacheDB

- (void)removeOldData
{
    NSTimeInterval removeRarelyAccessDataDelay = _cacheDBInfo.autoRemoveByLastAccessDate;
    
    if (removeRarelyAccessDataDelay > 0.) {
        
        NSDate *fromDate = [[NSDate new] dateByAddingTimeInterval:-removeRarelyAccessDataDelay];
        
        [self removeRecordsToAccessDate:fromDate];
    }
    
    unsigned long long bytes = _cacheDBInfo.autoRemoveByMaxSizeInMB * 1024 * 1024;
    
    if (bytes > 0) {
        
        [self removeRecordsWhileTotalSizeMoreThenBytes:bytes];
    }
}

- (void)runAutoRemoveDataSchedulerIfNeeds
{
    @synchronized(lockObject) {
        
        JFFTimer *timer = autoremoveSchedulersByCacheName[_cacheDBInfo.dbPropertyName];
        
        if (timer)
            return;
        
        if (!autoremoveSchedulersByCacheName)
            autoremoveSchedulersByCacheName = [NSMutableDictionary new];
        
        if (!timer) {
            timer = [JFFTimer new];
            autoremoveSchedulersByCacheName[_cacheDBInfo.dbPropertyName] = timer;
        }
        
        JFFScheduledBlock block = ^void(JFFCancelScheduledBlock cancel) {
            
            JFFSyncOperation loadDataBlock = ^id(NSError *__autoreleasing *outError) {
                
                [self removeOldData];
                return [NSNull new];
            };
            
            static const char *const queueName = "com.embedded_sources.dbcache.thread_to_remove_old_data";
            JFFAsyncOperation loader = asyncOperationWithSyncOperationAndQueue(loadDataBlock, queueName);
            
            loader(nil, nil, ^(id result, NSError *error) {
                
                [error writeErrorWithJFFLogger];
            });
        };
        block(nil);
        
        [timer addBlock:block duration:3600. leeway:1800.];
    }
}

- (instancetype)initWithCacheDBInfo:(CacheDBInfo *)dbInfo
{
    self = [super initWithCacheFileName:dbInfo.fileName];
    
    if (self) {
        _cacheDBInfo = dbInfo;
    }
    
    return self;
}

//JTODO check using of migrateDB method when multithreaded
- (void)migrateDB
{
    NSDictionary *currentDbInfo = [[JFFDBInfo sharedDBInfo] currentDbVersionsByName];
    NSNumber *currVersion = currentDbInfo[_cacheDBInfo.dbPropertyName];
    
    if (!currVersion) {
        return;
    }
    
    NSInteger lastVersion    = _cacheDBInfo.version;
    NSInteger currentVersion = [currVersion unsignedIntegerValue];
    
    if (lastVersion > currentVersion) {
        [self removeAllRecordsWithCallback:nil];
    }
}

- (NSNumber *)timeToLiveInHours
{
    CacheDBInfoStorage *dbInfo = [[JFFDBInfo sharedDBInfo] dbInfoByNames];
    NSNumber *result = [[dbInfo infoByDBName:_cacheDBInfo.dbPropertyName] timeToLiveInHours];
    return result;
}

@end

@interface JFFCaches ()

@property (nonatomic, readonly) NSMutableDictionary *mutableCacheDbByName;

@end

@implementation JFFCaches
{
    NSMutableDictionary *_mutableCacheDbByName;
}

- (id< JFFCacheDB >)registerAndCreateCacheDBWithName:(NSString *)dbPropertyName
                                              dbInfo:(JFFDBInfo *)dbInfo
{
    id< JFFCacheDB > result = self.mutableCacheDbByName[dbPropertyName];
    
    if (!result) {
        JFFInternalCacheDB *db = (JFFInternalCacheDB *)[[self class] createCacheForName:dbPropertyName];
        [db runAutoRemoveDataSchedulerIfNeeds];
        self.mutableCacheDbByName[dbPropertyName] = db;
        result = db;
    }
    
    return result;
}

- (void)setupCachesWithDBInfo:(JFFDBInfo *)dbInfo
{
    [dbInfo.dbInfoByNames enumerateKeysAndObjectsUsingBlock:^(NSString *dbName, CacheDBInfo *obj, BOOL *stop) {
        [self registerAndCreateCacheDBWithName:dbName
                                        dbInfo:dbInfo];
    }];
}

- (instancetype)initWithDBInfoDictionary:(NSDictionary *)cachesInfo
{
    JFFDBInfo *dbInfo = [[JFFDBInfo alloc]initWithInfoDictionary:cachesInfo];
    return [self initWithDBInfo:dbInfo];
}

- (instancetype)initWithDBInfo:(JFFDBInfo *)dbInfo
{
    self = [super init];
    
    if (self) {
        [self setupCachesWithDBInfo:dbInfo];
    }
    
    return self;
}

+ (JFFCaches *)sharedCaches
{
    if (!sharedCachesInstance) {
        JFFDBInfo *dbInfo = [JFFDBInfo sharedDBInfo];
        sharedCachesInstance = [[self alloc] initWithDBInfo:dbInfo];
    }
    
    return sharedCachesInstance;
}

+ (void)setSharedCaches:(JFFCaches *)caches
{
    sharedCachesInstance = caches;
}

- (NSMutableDictionary *)mutableCacheDbByName
{
    if (!_mutableCacheDbByName) {
        _mutableCacheDbByName = [NSMutableDictionary new];
    }
    
    return _mutableCacheDbByName;
}

- (NSDictionary *)cacheDbByName
{
    return self.mutableCacheDbByName;
}

- (id<JFFCacheDB>)cacheByName:(NSString *)name
{
    return self.cacheDbByName[name];
}

+ (NSString *)thumbnailDBName
{
    return @"JFF_THUMBNAIL_DB";
}

- (id<JFFCacheDB>)thumbnailDB
{
    return [self cacheByName:[[self class] thumbnailDBName]];
}

+ (id<JFFCacheDB>)createCacheForName:(NSString *)name
{
    JFFDBInfo *dbInfo = [JFFDBInfo sharedDBInfo];
    
    return [[JFFInternalCacheDB alloc] initWithCacheDBInfo:[dbInfo.dbInfoByNames infoByDBName:name]];
}

+ (id<JFFCacheDB>)createThumbnailDB
{
    return [self createCacheForName:[[self class] thumbnailDBName]];
}

- (void)migrateDBs
{
    NSDictionary *cacheDbByName = [self cacheDbByName];
    [cacheDbByName enumerateKeysAndObjectsUsingBlock:^(id key, JFFInternalCacheDB *db, BOOL *stop) {
        [db migrateDB];
    }];
    
    [[JFFDBInfo sharedDBInfo] saveCurrentDBInfoVersions];
}

@end
