#import "JFFDBInfo.h"

static JFFDBInfo* sharedInfo = nil;

@interface JFFDBInfo ()

@property (nonatomic) NSString *dbInfoPath;

@end

@implementation JFFDBInfo
{
    NSDictionary *_currentDbInfo;
    NSDictionary *_dbInfo;
}

- (id)initWithInfoPath:(NSString *)infoPath
{
    self = [super init];
    
    if (self) {
        _dbInfoPath = infoPath;
    }
    
    return self;
}

- (id)initWithInfoDictionary:(NSDictionary *)infoDictionry
{
    self = [super init];
    
    if (self) {
        _currentDbInfo = infoDictionry;
    }
    
    return self;
}

- (NSDictionary *)createDBInfo
{
    return _currentDbInfo?:[NSDictionary dictionaryWithContentsOfFile:_dbInfoPath];
}

- (NSDictionary *)dbInfo
{
    if (_dbInfo)
        return _dbInfo;
    
    @synchronized(self) {
        if (_dbInfo)
            return _dbInfo;
        
        _dbInfo = [self createDBInfo];
    }
    return _dbInfo;
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
    return [NSString documentsPathByAppendingPathComponent:@"JFFCurrentDBInfo.data"] ;
}

- (NSDictionary *)currentDbInfo
{
    if (_currentDbInfo)
        return _currentDbInfo;
    
    @synchronized(self) {
        if (_currentDbInfo)
            return _currentDbInfo;
        
        NSString *path = [[self class] currentDBInfoFilePath];
        NSDictionary *currentDbInfo = [[NSDictionary alloc] initWithContentsOfFile:path];
        self.currentDbInfo = currentDbInfo?:@{};
    }
    
    return _currentDbInfo;
}

- (void)setCurrentDbInfo:(NSDictionary *)currentDbInfo
{
    if (_currentDbInfo == currentDbInfo)
        return;
    
    @synchronized(self) {
        if (_currentDbInfo == currentDbInfo)
            return;
        
        _currentDbInfo = currentDbInfo?:@{};
        
        NSString *path = [[self class] currentDBInfoFilePath];
        [_currentDbInfo writeToFile:path atomically:YES];
        [path addSkipBackupAttribute];
    }
}

@end
