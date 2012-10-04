#import "JFFDBInfo.h"

static JFFDBInfo *sharedInfo = nil;

static NSString *const timeToLiveInHours = @"timeToLiveInHours";

@interface JFFDBInfo ()

@property (nonatomic) NSString *dbInfoPath;

@end

@implementation JFFDBInfo
{
    //try to remove this ivar
    NSDictionary* _currentDbInfo;
    
    NSDictionary* _dbInfo;
}

-(id)initWithInfoPath:( NSString* )infoPath
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
    if (!self->_dbInfo) {
        self->_dbInfo = [self createDBInfo];
    }
    return self->_dbInfo;
}

+ (JFFDBInfo *)newDbInfo
{
    NSString *defaultPath = [[NSBundle mainBundle]pathForResource:@"JFFCacheDBInfo" ofType:@"plist"];
    return [[self alloc]initWithInfoPath:defaultPath];
}

+ (JFFDBInfo *)sharedDBInfo
{
    if (!sharedInfo) {
        sharedInfo = [self newDbInfo];
    }
    
    return sharedInfo;
}

+ (void)setSharedDBInfo:(JFFDBInfo *)dbInfo
{
    sharedInfo = dbInfo;
}

+ (NSString *)currentDBInfoFilePath
{
    //TODO add flag - do not store into iCoud
    return [NSString documentsPathByAppendingPathComponent:@ "JFFCurrentDBInfo.data"] ;
}

- (NSDictionary *)currentDbInfo
{
    if (!self->_currentDbInfo) {
        self->_currentDbInfo = [[NSDictionary alloc]initWithContentsOfFile:[[self class]currentDBInfoFilePath]];
    }
    
    return self->_currentDbInfo;
}

- (void)setCurrentDbInfo:(NSDictionary *)currentDbInfo
{
    if (self->_currentDbInfo == currentDbInfo)
        return;
    
    self->_currentDbInfo = currentDbInfo?:@{};
    
    [self->_currentDbInfo writeToFile:[[self class]currentDBInfoFilePath]atomically:YES];
}

@end

@implementation NSDictionary (DBInfo)

- (NSString*)fileNameForDBWithName:(NSString *)name
{
    return self[name][@"fileName"];
}

- (NSNumber*)timeToLiveInHoursForDBWithName:(NSString *)name
{
    NSNumber *result = self[name][timeToLiveInHours];
    return result;
}

- (NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:(NSString *)name
{
    NSNumber *number = self[name][@"autoRemoveByLastAccessDateInHours"];
    return number?[number doubleValue] * 3600. : 0.;
}

- (NSUInteger)versionForDBWithName:(NSString *)name
{
    return [self[name][@"version"]intValue];
}

@end
