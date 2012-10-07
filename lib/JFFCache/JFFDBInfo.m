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
        self->_dbInfoPath = infoPath;
    }
    
    return self;
}

- (id)initWithInfoDictionary:(NSDictionary *)infoDictionry
{
    self = [super init];
    
    if (self) {
        self->_currentDbInfo = infoDictionry;
    }
    
    return self;
}

- (NSDictionary *)createDBInfo
{
    return self->_currentDbInfo?:[NSDictionary dictionaryWithContentsOfFile:self->_dbInfoPath];
}

- (NSDictionary *)dbInfo
{
    if (self->_dbInfo)
        return self->_dbInfo;
    
    @synchronized(self) {
        if (self->_dbInfo)
            return self->_dbInfo;
        
        self->_dbInfo = [self createDBInfo];
    }
    return self->_dbInfo;
}

+ (JFFDBInfo *)newDbInfo
{
    NSString *defaultPath = [[NSBundle mainBundle]pathForResource:@"JFFCacheDBInfo" ofType:@"plist"];
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
    if (self->_currentDbInfo)
        return self->_currentDbInfo;
    
    @synchronized(self) {
        if (self->_currentDbInfo)
            return self->_currentDbInfo;
        
        NSString *path = [[self class] currentDBInfoFilePath];
        self->_currentDbInfo = [[NSDictionary alloc] initWithContentsOfFile:path];
        self->_currentDbInfo = self->_currentDbInfo?:@{};
    }
    
    return self->_currentDbInfo;
}

- (void)setCurrentDbInfo:(NSDictionary *)currentDbInfo
{
    if (self->_currentDbInfo == currentDbInfo)
        return;
    
    @synchronized(self) {
        if (self->_currentDbInfo == currentDbInfo)
            return;
        
        self->_currentDbInfo = currentDbInfo?:@{};
        
        NSString *path = [[self class] currentDBInfoFilePath];
        [self->_currentDbInfo writeToFile:path atomically:YES];
        [path addSkipBackupAttribute];
    }
}

@end
