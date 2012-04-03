#import "JFFCaches.h"

#import "JFFCacheDB.h"
#import "JFFBaseDB.h"
#import "JFFDBInfo.h"

#import <JFFUtils/NSObject/NSObject+OnDeallocBlock.h>
#import <JFFUtils/NSArray/NSArray+BlocksAdditions.h>
#import <JFFScheduler/JFFScheduler.h>

@interface JFFInternalCacheDB : JFFBaseDB
{
    NSString* _config_property_name;
}

@property ( nonatomic, strong ) NSString* configPropertyName;

@end

@implementation JFFInternalCacheDB

@synthesize configPropertyName;

-(id)initWithCacheDBWithName:( NSString* )config_property_name_
{
    NSString* db_name_ = [ [ [ JFFDBInfo sharedDBInfo ] dbInfo ] fileNameForDBWithName: config_property_name_ ];

    self = [ super initWithDBName: db_name_ cacheName: config_property_name_ ];

    if ( self )
    {
        self.configPropertyName = config_property_name_;

        NSDictionary* db_info_ = [ [ JFFDBInfo sharedDBInfo ] dbInfo ];
        NSTimeInterval remove_rarely_access_data_delay_ = [ db_info_ autoRemoveByLastAccessDateForDBWithName: self.configPropertyName ];
        if ( remove_rarely_access_data_delay_ != 0 )
        {
            __weak JFFInternalCacheDB* self_ = self;
            JFFScheduledBlock block_ = ^void( JFFCancelScheduledBlock cancel_ )
            {
                NSDate* from_date_ = [ [ NSDate date ] addTimeInterval: -remove_rarely_access_data_delay_ ];
                [ self_ removeRecordsToAccessDate: from_date_ ];
            };
            block_( nil );
            [ self addOnDeallocBlock: [ [ JFFScheduler sharedByThreadScheduler ] addBlock: block_ duration: 3600. ] ];
        }
    }

    return self;
}

+(id)internalCacheDBWithName:( NSString* )db_property_name_
{
    return [ [ self alloc ] initWithCacheDBWithName: db_property_name_ ];
}

-(void)migrateDB
{
    NSDictionary* currentDbInfo_ = [ [ JFFDBInfo sharedDBInfo ] currentDbInfo ];
    if ( !currentDbInfo_ )
    {
        return;
    }

    NSDictionary* dbInfo_ = [ [ JFFDBInfo sharedDBInfo ] dbInfo ];

    NSInteger lastVersion_ = [ dbInfo_ versionForDBWithName: _config_property_name ];
    NSInteger current_version_ = [ currentDbInfo_ versionForDBWithName: _config_property_name ];

    if ( lastVersion_ > current_version_ )
    {
        [ self removeAllRecords ];
    }
}

@end

@interface JFFCaches ()

@property ( nonatomic, strong, readonly ) NSMutableDictionary* mutableCacheDbByName;

@end

@implementation JFFCaches
{
    NSMutableDictionary* _mutableCacheDbByName;
}

-(id< JFFCacheDB >)registerAndCreateCacheDBWithName:( NSString* )db_property_name_
{
    id< JFFCacheDB > result_ = [ self.mutableCacheDbByName objectForKey: db_property_name_ ];

    if ( !result_ )
    {
        result_ = [ JFFInternalCacheDB internalCacheDBWithName: db_property_name_ ];

        [ self.mutableCacheDbByName setObject: result_ forKey: db_property_name_ ];
    }

    return result_;
}

-(id)init
{
    self = [ super init ];

    if ( self )
    {
        NSDictionary* db_info_ = [ [ JFFDBInfo sharedDBInfo ] dbInfo ];

        [ [ db_info_ allKeys ] each: ^void( id db_name_ )
        {
            [ self registerAndCreateCacheDBWithName: db_name_ ];
        } ];
    }

    return self;
}


+(JFFCaches*)sharedCaches
{
    static id instance_ = nil;

    if ( !instance_ )
    {
        instance_ = [ self new ];
    }

    return instance_;
}

-(NSMutableDictionary*)mutableCacheDbByName
{
    if ( !_mutableCacheDbByName )
    {
        _mutableCacheDbByName = [ NSMutableDictionary new ];
    }

    return _mutableCacheDbByName;
}

-(NSDictionary*)cacheDbByName
{
    return self.mutableCacheDbByName;
}

-(id< JFFCacheDB >)cacheByName:( NSString* )name_
{
    return [ self.cacheDbByName objectForKey: name_ ];
}

-(id< JFFCacheDB >)thumbnailDB
{
    return [ self cacheByName: @"JFF_THUMBNAIL_DB" ];
}

@end
