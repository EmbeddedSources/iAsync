#import "JFFCaches.h"

#import "JFFCacheDB.h"
#import "JFFBaseDB.h"
#import "JFFDBInfo.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>
#import <JFFScheduler/JFFScheduler.h>

static JFFCaches* sharedCachesInstance_ = nil;

@interface JFFInternalCacheDB : JFFBaseDB

@property ( nonatomic ) NSString* configPropertyName;

@end

@implementation JFFInternalCacheDB

-(void)configureCachesWithCacheDBWithName:( NSString* )dbPropertyName_
                                   dbInfo:( JFFDBInfo* )dbInfo_
{
    self->_configPropertyName = dbPropertyName_;

    NSDictionary* dbInfoDict_ = [ dbInfo_ dbInfo ];
    NSTimeInterval removeRarelyAccessDataDelay_ =
        [ dbInfoDict_ autoRemoveByLastAccessDateForDBWithName: self->_configPropertyName ];
    if ( removeRarelyAccessDataDelay_ != 0 )
    {
        __weak JFFInternalCacheDB* self_ = self;
        JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ )
        {
            NSDate* fromDate_ = [ [ NSDate new ] dateByAddingTimeInterval: -removeRarelyAccessDataDelay_ ];
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
    NSDictionary* currentDbInfo_ = [ [ JFFDBInfo sharedDBInfo ] currentDbInfo ];
    if ( !currentDbInfo_ )
    {
        return;
    }

    NSDictionary* dbInfo_ = [ [ JFFDBInfo sharedDBInfo ] dbInfo ];

    NSInteger lastVersion_ = [ dbInfo_ versionForDBWithName: self->_configPropertyName ];
    NSInteger current_version_ = [ currentDbInfo_ versionForDBWithName: self->_configPropertyName ];

    if ( lastVersion_ > current_version_ )
    {
        [ self removeAllRecords ];
    }
}

@end

@interface JFFCaches ()

@property ( nonatomic, readonly ) NSMutableDictionary* mutableCacheDbByName;

@end

@implementation JFFCaches
{
    NSMutableDictionary* _mutableCacheDbByName;
}

-(id< JFFCacheDB >)registerAndCreateCacheDBWithName:( NSString* )dbPropertyName_
                                             dbInfo:( JFFDBInfo* )dbInfo_
{
    id< JFFCacheDB > result_ = self.mutableCacheDbByName[ dbPropertyName_ ];

    if ( !result_ )
    {
        result_ = [ JFFInternalCacheDB internalCacheDBWithName: dbPropertyName_
                                                        dbInfo: dbInfo_ ];
        self.mutableCacheDbByName[ dbPropertyName_ ] = result_;
    }

    return result_;
}

-(void)setupCachesWithDBInfo:( JFFDBInfo* )dbInfo_
{
    [ dbInfo_.dbInfo enumerateKeysAndObjectsUsingBlock: ^( id dbName_, id obj, BOOL* stop )
    {
        [ self registerAndCreateCacheDBWithName: dbName_
                                         dbInfo: dbInfo_ ];
    } ];
}

-(id)initWithDBInfoDictionary:( NSDictionary* )cachesInfo_
{
    JFFDBInfo* dbInfo_ = [ [ JFFDBInfo alloc ] initWithInfoDictionary: cachesInfo_ ];
    return [ self initWithDBInfo: dbInfo_ ];  
}

-(id)initWithDBInfo:( JFFDBInfo* )dbInfo_
{
    self = [ super init ];

    if ( self )
    {
        [ self setupCachesWithDBInfo: dbInfo_ ];
    }

    return self;
}

+(JFFCaches*)sharedCaches
{
    if ( !sharedCachesInstance_ )
    {
        JFFDBInfo* dbInfo_ = [ JFFDBInfo sharedDBInfo ];
        sharedCachesInstance_ = [ [ self alloc ] initWithDBInfo: dbInfo_ ];
    }

    return sharedCachesInstance_;
}

+(void)setSharedCaches:( JFFCaches* )caches_
{
    sharedCachesInstance_ = caches_;
}

-(NSMutableDictionary*)mutableCacheDbByName
{
    if ( !self->_mutableCacheDbByName )
    {
        self->_mutableCacheDbByName = [ NSMutableDictionary new ];
    }

    return self->_mutableCacheDbByName;
}

-(NSDictionary*)cacheDbByName
{
    return self.mutableCacheDbByName;
}

-(id< JFFCacheDB >)cacheByName:( NSString* )name_
{
    return self.cacheDbByName[ name_ ];
}

-(id< JFFCacheDB >)thumbnailDB
{
    return [ self cacheByName: @"JFF_THUMBNAIL_DB" ];
}

@end
