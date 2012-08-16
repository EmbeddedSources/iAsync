#import "JFFDBInfo.h"

static JFFDBInfo* sharedInfo_ = nil;

static NSString* const timeToLiveInHours_ = @"timeToLiveInHours";

@interface JFFDBInfo ()

@property ( nonatomic ) NSString* dbInfoPath;

@end

@implementation JFFDBInfo
{
    //try to remove this ivar
    NSDictionary* _currentDbInfo;

    NSDictionary* _dbInfo;
}

-(id)initWithInfoPath:( NSString* )infoPath_
{
    self = [ super init ];

    if ( self )
    {
        self->_dbInfoPath = infoPath_;
    }

    return self;
}

-(id)initWithInfoDictionary:( NSDictionary* )infoDictionry_
{
    self = [ super init ];

    if ( self )
    {
        self->_currentDbInfo = infoDictionry_;
    }

    return self;
}

-(NSDictionary*)createDBInfo
{
    return self->_currentDbInfo ? : [ NSDictionary dictionaryWithContentsOfFile: self->_dbInfoPath ];
}

-(NSDictionary*)dbInfo
{
    if ( !self->_dbInfo )
    {
        self->_dbInfo = [ self createDBInfo ];
    }
    return self->_dbInfo;
}

+(JFFDBInfo*)sharedDBInfo
{
    if ( !sharedInfo_ )
    {
        NSString* defaultPath_ = [ [ NSBundle mainBundle ] pathForResource: @"DBInfo" ofType: @"plist" ];
        sharedInfo_ = [ [ self alloc ] initWithInfoPath: defaultPath_ ];
    }

    return sharedInfo_;
}

+(void)setSharedDBInfo:( JFFDBInfo* )dbInfo_
{
    sharedInfo_ = dbInfo_;
}

+(NSString*)currentDBInfoFilePath
{
    return [ NSString documentsPathByAppendingPathComponent: @"JFFCurrentDBInfo.data" ];
}

-(NSDictionary*)currentDbInfo
{
    if ( !self->_currentDbInfo )
    {
        self->_currentDbInfo = [ [ NSDictionary alloc ] initWithContentsOfFile: [ [ self class ] currentDBInfoFilePath ] ];
    }

    return self->_currentDbInfo;
}

-(void)setCurrentDbInfo:( NSDictionary* )currentDbInfo_
{
    if ( self->_currentDbInfo == currentDbInfo_ )
        return;

    self->_currentDbInfo = currentDbInfo_ ?: @{};

    [ self->_currentDbInfo writeToFile: [ [ self class ] currentDBInfoFilePath ] atomically: YES ];
}

@end

@implementation NSDictionary (DBInfo)

-(NSString*)fileNameForDBWithName:( NSString* )name_
{
    return [ [ self objectForKey: name_ ] objectForKey: @"fileName" ];
}

-(NSTimeInterval)timeToLiveForDBWithName:( NSString* )name_
{
    NSTimeInterval hours_ = [ [ [ self objectForKey: name_ ] objectForKey: timeToLiveInHours_ ] doubleValue ];
    return hours_ * 3600.;
}

-(NSTimeInterval)autoRemoveByLastAccessDateForDBWithName:( NSString* )name_
{
    NSNumber* number_ = [ [ self objectForKey: name_ ] objectForKey: @"autoRemoveByLastAccessDateInHours" ];
    return number_ ? [ number_ doubleValue ] * 3600. : 0.;
}

-(NSUInteger)versionForDBWithName:( NSString* )name_
{
    return [ [ [ self objectForKey: name_ ] objectForKey: @"version" ] intValue ];
}

-(BOOL)hasExpirationDateDBWithName:( NSString* )name_
{
    return [ [ self objectForKey: name_ ] objectForKey: timeToLiveInHours_ ] != nil;
}

@end
