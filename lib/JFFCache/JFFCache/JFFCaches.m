#import "JFFCaches.h"

#import "JFFCacheDB.h"
#import "JFFBaseDB.h"
#import "JFFDBInfo.h"

#import "NSDictionary+DBInfo.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>
#import <JFFScheduler/JFFScheduler.h>

static JFFCaches* sharedCachesInstance;

static NSMutableDictionary *autoremoveSchedulersByCacheName;
static NSString *const lockObject = @"41d318da-1229-4a50-9222-4ad870c56ecc";

@interface JFFInternalCacheDB : JFFBaseDB <JFFCacheDB>

@property (nonatomic) NSString *configPropertyName;

@end

@implementation JFFInternalCacheDB

+ (void)removeOldDataWithAutoremoveProperties:(NSDictionary *)autoremoveProperties
                               dbPropertyName:(NSString *)dbPropertyName
                                       dbInfo:(JFFDBInfo *)dbInfo
{
    NSTimeInterval removeRarelyAccessDataDelay = [autoremoveProperties autoRemoveByLastAccessDate];
    
    JFFInternalCacheDB *cacheDB = [[self alloc] initWithCacheDBWithName:dbPropertyName
                                                                 dbInfo:dbInfo];
    
    if (removeRarelyAccessDataDelay > 0.) {
        
        NSDate *fromDate = [[NSDate new] dateByAddingTimeInterval:-removeRarelyAccessDataDelay];
        
        [cacheDB removeRecordsToAccessDate:fromDate];
    }
    
    unsigned long long bytes = [autoremoveProperties autoRemoveByMaxSizeInMB] * 1024 * 1024;
    
    if (bytes > 0) {
        
        [cacheDB removeRecordsWhileTotalSizeMoreThenBytes:bytes];
    }
}

+ (void)runAutoremoveDataSchedulerWithName:(NSString *)dbPropertyName
                      autoremoveProperties:(NSDictionary *)autoremoveProperties
                                    dbInfo:(JFFDBInfo *)dbInfo
{
    @synchronized(lockObject) {
        JFFScheduler *scheduler = autoremoveSchedulersByCacheName[dbPropertyName];
        
        if (scheduler)
            return;
        
        if (!autoremoveSchedulersByCacheName)
            autoremoveSchedulersByCacheName = [NSMutableDictionary new];
        
        if (!scheduler) {
            scheduler = [JFFScheduler new];
            autoremoveSchedulersByCacheName[dbPropertyName] = scheduler;
        }
        
        JFFScheduledBlock block = ^void(JFFCancelScheduledBlock cancel) {
            
            JFFSyncOperation loadDataBlock = ^id(NSError *__autoreleasing *outError) {
                
                [self removeOldDataWithAutoremoveProperties:autoremoveProperties
                                             dbPropertyName:dbPropertyName
                                                     dbInfo:dbInfo];
                
                return [NSNull new];
            };
            
            static const char *const queueName = "com.embedded_sources.dbcache.thread_to_remove_old_data";
            JFFAsyncOperation loader = asyncOperationWithSyncOperationAndQueue(loadDataBlock, queueName);
            
            loader(nil, nil, ^(id result, NSError *error) {
                
                [error writeErrorWithJFFLogger];
            });
        };
        block(nil);
        
        [scheduler addBlock:block duration:3600.];
    }
}

+ (void)runAutoremoveDataSchedulerIfNeedsWithName:(NSString *)dbPropertyName
                                           dbInfo:(JFFDBInfo *)dbInfo
{
    NSDictionary *dbInfoDict = [dbInfo currentDbInfo];
    NSDictionary *autoremoveProperties =
    [dbInfoDict autoRemoveProperiesForDBWithName:dbPropertyName];
    
    if (autoremoveProperties) {
        
        [self runAutoremoveDataSchedulerWithName:dbPropertyName
                            autoremoveProperties:autoremoveProperties
                                          dbInfo:dbInfo];
    }
}

- (instancetype)initWithCacheDBWithName:(NSString *)dbPropertyName
                                 dbInfo:(JFFDBInfo *)dbInfo
{
    NSString *filePath = [[dbInfo dbInfo] fileNameForDBWithName:dbPropertyName];
    
    self = [super initWithCacheFileName:filePath];
    
    if (self) {
        _configPropertyName = dbPropertyName;
    }
    
    return self;
}

//JTODO check using of migrateDB method when multithreaded
- (void)migrateDB
{
    NSDictionary *currentDbInfo = [[JFFDBInfo sharedDBInfo] currentDbInfo];
    if (!currentDbInfo) {
        return;
    }
    
    NSDictionary *dbInfo = [[JFFDBInfo sharedDBInfo] dbInfo];
    
    NSInteger lastVersion    = [dbInfo versionForDBWithName:_configPropertyName];
    NSInteger currentVersion = [currentDbInfo versionForDBWithName:_configPropertyName];
    
    if (lastVersion > currentVersion) {
        [self removeAllRecordsWithCallback:nil];
    }
}

- (NSNumber *)timeToLiveInHours
{
    NSDictionary *dbInfo = [[JFFDBInfo sharedDBInfo] currentDbInfo];
    NSNumber *result = [dbInfo timeToLiveInHoursForDBWithName:_configPropertyName];
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
        result = [[self class] createCacheForName:dbPropertyName
                                           dbInfo:dbInfo];
        self.mutableCacheDbByName[dbPropertyName] = result;
    }
    
    return result;
}

- (void)setupCachesWithDBInfo:(JFFDBInfo *)dbInfo
{
    [dbInfo.dbInfo enumerateKeysAndObjectsUsingBlock:^(id dbName, id obj, BOOL *stop) {
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

- (id< JFFCacheDB >)cacheByName:(NSString *)name
{
    return self.cacheDbByName[name];
}

- (id< JFFCacheDB >)thumbnailDB
{
    return [self cacheByName:@"JFF_THUMBNAIL_DB"];
}

+ (id< JFFCacheDB >)createCacheForName:(NSString *)name
                                dbInfo:(JFFDBInfo *)dbInfo
{
    id< JFFCacheDB > result = [[JFFInternalCacheDB alloc ] initWithCacheDBWithName:name
                                                                            dbInfo:dbInfo];
    
    [JFFInternalCacheDB runAutoremoveDataSchedulerIfNeedsWithName:name
                                                           dbInfo:dbInfo];
    
    return result;
}

+ (id< JFFCacheDB >)createCacheForName:(NSString *)name
{
    JFFDBInfo *dbInfo = [JFFDBInfo sharedDBInfo];
    
    return [self createCacheForName:name
                             dbInfo:dbInfo];
}

+ (id< JFFCacheDB >)createThumbnailDB
{
    return [self createCacheForName:@"JFF_THUMBNAIL_DB"];
}

@end
