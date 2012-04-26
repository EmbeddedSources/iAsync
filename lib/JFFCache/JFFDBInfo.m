#import "JFFDBInfo.h"

static JFFDBInfo* sharedInfo_ = nil;

static NSString* const time_to_live_in_hours_ = @"timeToLiveInHours";

@interface JFFDBInfo ()

@property ( nonatomic, strong ) NSString* dbInfoPath;

@end

@implementation JFFDBInfo

@synthesize currentDbInfo, dbInfo, dbInfoPath;

-(id)initWithInfoPath:( NSString* )infoPath_
{
    self = [ super init ];

    self.dbInfoPath = infoPath_;

    return self;
}

-(id)initWithInfoDictionary:( NSDictionary* )infoDictionry_
{
    self = [ super init ];

    if ( self )
    {
        currentDbInfo = infoDictionry_;
    }

    return self;
}

-(NSDictionary*)createDBInfo
{
    return currentDbInfo ? : [ NSDictionary dictionaryWithContentsOfFile: dbInfoPath ];
}

-(NSDictionary*)dbInfo
{
    if ( !dbInfo )
    {
        dbInfo = [ self createDBInfo ];
    }
    return dbInfo;
}

+(JFFDBInfo*)sharedDBInfo
{
    if ( !sharedInfo_ )
    {
        NSString* default_path_ = [ [ NSBundle mainBundle ] pathForResource: @"DBInfo" ofType: @"plist" ];
        sharedInfo_ = [ [ self alloc ] initWithInfoPath: default_path_ ];
    }

    return sharedInfo_;
}

+(void)setSharedDBInfo:( JFFDBInfo* )db_info_
{
    sharedInfo_ = db_info_;
}

+(NSString*)currentDBInfoFilePath
{
    return [ NSString documentsPathByAppendingPathComponent: @"JFFCurrentDBInfo.data" ];
}

-(NSDictionary*)currentDbInfo
{
    if ( !currentDbInfo )
    {
        currentDbInfo = [ [ NSDictionary alloc ] initWithContentsOfFile: [ [ self class ] currentDBInfoFilePath ] ];
    }

    return currentDbInfo;
}

-(void)setCurrentDbInfo:( NSDictionary* )current_db_info_
{
    if ( currentDbInfo == current_db_info_ )
        return;

    currentDbInfo = current_db_info_;

    [ currentDbInfo writeToFile: [ [ self class ] currentDBInfoFilePath ] atomically: YES ];
}

@end

@implementation NSDictionary (DBInfo)

-(NSString*)fileNameForDBWithName:( NSString* )name_
{
    return [ [ self objectForKey: name_ ] objectForKey: @"fileName" ];
}

-(NSTimeInterval)timeToLiveForDBWithName:( NSString* )name_
{
    NSTimeInterval hours_ = [ [ [ self objectForKey: name_ ] objectForKey: time_to_live_in_hours_ ] doubleValue ];
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
    return [ [ self objectForKey: name_ ] objectForKey: time_to_live_in_hours_ ] != nil;
}

@end
