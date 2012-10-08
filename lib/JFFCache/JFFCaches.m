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

+ (void)runAutoremoveDataSchedulerWithName:(NSString *)dbPropertyName
               removeRarelyAccessDataDelay:(NSTimeInterval)removeRarelyAccessDataDelay
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
            
            NSDate *fromDate = [[NSDate new] dateByAddingTimeInterval:-removeRarelyAccessDataDelay];
            
            JFFSyncOperation loadDataBlock = ^id(NSError *__autoreleasing *outError) {
                JFFInternalCacheDB *cacheDB = [[self alloc] initWithCacheDBWithName:dbPropertyName
                                                                             dbInfo:dbInfo];
                
                [cacheDB removeRecordsToAccessDate:fromDate];
                return [NSNull new];
            };
            
            static const char *const queueName = "com.embedded_sources.dbcache.thread_to_remove_old_data";
            JFFAsyncOperation loader = asyncOperationWithSyncOperationAndQueue(loadDataBlock, queueName);
            
            loader(nil, nil, nil);
        };
        block(nil);
        
        [scheduler addBlock:block duration:3600.];
    }
}

+ (void)runAutoremoveDataSchedulerIfNeedsWithName:(NSString *)dbPropertyName
                                           dbInfo:(JFFDBInfo *)dbInfo
{
    NSDictionary *dbInfoDict = [dbInfo dbInfo];
    NSTimeInterval removeRarelyAccessDataDelay =
    [dbInfoDict autoRemoveByLastAccessDateForDBWithName:dbPropertyName];
    
    if (removeRarelyAccessDataDelay != 0) {
        
        [self runAutoremoveDataSchedulerWithName:dbPropertyName
                     removeRarelyAccessDataDelay:removeRarelyAccessDataDelay
                                          dbInfo:dbInfo];
    }
}

- (id)initWithCacheDBWithName:(NSString *)dbPropertyName
                       dbInfo:(JFFDBInfo *)dbInfo
{
    self = [super initWithCacheFileName:dbPropertyName];
    
    if (self) {
        self->_configPropertyName = dbPropertyName;
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
    
    NSInteger lastVersion    = [dbInfo versionForDBWithName:self->_configPropertyName];
    NSInteger currentVersion = [currentDbInfo versionForDBWithName:self->_configPropertyName];
    
    if (lastVersion > currentVersion) {
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

- (id)initWithDBInfoDictionary:(NSDictionary *)cachesInfo
{
    JFFDBInfo *dbInfo = [[JFFDBInfo alloc]initWithInfoDictionary:cachesInfo];
    return [self initWithDBInfo:dbInfo];
}

- (id)initWithDBInfo:(JFFDBInfo *)dbInfo
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
    if (!self->_mutableCacheDbByName) {
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
