#import "JFFDBInfo.h"

#import "CacheDBInfo.h"
#import "CacheDBInfoStorage.h"

static JFFDBInfo *sharedInfo = nil;

@interface JFFDBInfo ()

@property (nonatomic) NSString *dbInfoPath;

@end

@implementation JFFDBInfo
{
    NSDictionary *_currentDbVersionsByName;
    CacheDBInfoStorage *_dbInfoByNames;
}

- (instancetype)initWithInfoPath:(NSString *)infoPath
{
    self = [super init];
    
    if (self) {
        _dbInfoPath = infoPath;
    }
    
    return self;
}

- (instancetype)initWithInfoDictionary:(NSDictionary *)infoDictionry
{
    self = [super init];
    
    if (self) {
        _dbInfoByNames = [CacheDBInfoStorage newCacheDBInfoStorageWithPlistInfo:infoDictionry];
    }
    
    return self;
}

- (CacheDBInfoStorage *)createDBInfo
{
    id info = [NSDictionary dictionaryWithContentsOfFile:_dbInfoPath];
    return [CacheDBInfoStorage newCacheDBInfoStorageWithPlistInfo:info];
}

- (CacheDBInfoStorage *)dbInfoByNames
{
    if (_dbInfoByNames)
        return _dbInfoByNames;
    
    @synchronized(self) {
        if (_dbInfoByNames)
            return _dbInfoByNames;
        
        _dbInfoByNames = [self createDBInfo];
    }
    return _dbInfoByNames;
}

+ (JFFDBInfo *)newDbInfo
{
    NSString *defaultPath = [[NSBundle mainBundle] pathForResource:@"JFFCacheDBInfo" ofType:@"plist"];
    return [[self alloc] initWithInfoPath:defaultPath];
}

+ (JFFDBInfo *)sharedDBInfo
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self newDbInfo];
    });
    return instance;
}

+ (void)setSharedDBInfo:(JFFDBInfo *)dbInfo
{
    sharedInfo = dbInfo;
}

+ (NSString *)currentDBInfoFilePath
{
    return [NSString documentsPathByAppendingPathComponent:@"JFFCurrentDBVersions.data"];
}

- (NSDictionary *)currentDbVersionsByName
{
    if (_currentDbVersionsByName)
        return _currentDbVersionsByName;
    
    @synchronized(self) {
        if (_currentDbVersionsByName)
            return _currentDbVersionsByName;
        
        NSString *path = [[self class] currentDBInfoFilePath];
        NSDictionary *currentDbInfo = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        if ([currentDbInfo count] > 0)
            _currentDbVersionsByName = currentDbInfo;
    }
    
    return _currentDbVersionsByName;
}

- (void)saveCurrentDBInfoVersions
{
    @synchronized(self) {
        
        NSMutableDictionary *mutableCurrentVersions = [NSMutableDictionary new];
        
        [self.dbInfoByNames enumerateKeysAndObjectsUsingBlock:^(NSString *key, CacheDBInfo *obj, BOOL *stop) {
            
            mutableCurrentVersions[key] = @(obj.version);
        }];
        
        NSDictionary *currentVersions = [mutableCurrentVersions copy];
        
        if ([self.currentDbVersionsByName isEqual:currentVersions])
            return;
        
        _currentDbVersionsByName = currentVersions;
        
        NSString *path = [[self class] currentDBInfoFilePath];
        [currentVersions writeToFile:path atomically:YES];
        [path addSkipBackupAttribute];
    }
}

@end
