
#import <JFFCache/JFFCache.h>
#import <JFFUtils/JFFUtils.h>

@interface JFFCachesTest : GHTestCase
@end

@implementation JFFCachesTest

-(void)testJFFCaches
{
    NSString *cacheName = @"URL_CACHES";
    
    id< JFFCacheDB > db = [[JFFCaches sharedCaches] cacheByName: cacheName ];
    
    GHAssertTrue(nil != db                          , @"can't init database with caches");
    GHAssertTrue([cacheName isEqualToString:db.name], @"cache db name should be correct");
    
    NSString *key_           = @"key1";
    NSString *stringToStore_ = @"test Data";
    NSData   *dataToStore_   = [ stringToStore_ dataUsingEncoding: NSUTF8StringEncoding ];
    NSDate   *updatedDate_   = nil;
    
    NSData* storedData_ = [ db dataForKey: key_ lastUpdateTime: &updatedDate_ ];

    GHAssertTrue( nil == storedData_ , @"db should be epmty"         );
    GHAssertTrue( nil == updatedDate_, @"updated date should be nil" );
    
    //-------------- set Data

    [ db setData: dataToStore_
           forKey: key_ ];
    
    //-------------- read with updated data
    
    storedData_ = [ db dataForKey: key_ lastUpdateTime: &updatedDate_ ];

    NSString* storedString = [ [ NSString alloc ] initWithData: storedData_ encoding: NSUTF8StringEncoding ];

    GHAssertTrue( nil != storedData_                              , @"stored data should not be nil"            );
    GHAssertTrue( [ storedString isEqualToString: stringToStore_ ], @"stored and readed string should be equal" );
    
    //-------------- read without updated data

    storedData_ = [ db dataForKey: key_ ];
    
    storedString = [ [ NSString alloc ] initWithData: storedData_ encoding: NSUTF8StringEncoding ];
    
    GHAssertTrue( nil != storedData_                              , @"stored data should not be nil 1"            );
    GHAssertTrue( [ storedString isEqualToString: stringToStore_ ], @"stored and readed string should be equal 1" );
 
    //-------------- remove records

    [ db removeRecordsForKey: key_ ];

    storedData_ = [ db dataForKey: key_ ];

    storedString = [ [ NSString alloc ] initWithData: storedData_ encoding: NSUTF8StringEncoding ];

    GHAssertTrue( nil == storedData_                                , @"stored data should be nil 1"            );
    GHAssertTrue( ! [ storedString isEqualToString: stringToStore_ ], @"stored and readed string should not be equal" );
}

-(void)testJFFCachesWithDBDiscriptionDictionary
{
    NSString *cacheName = @"URL_CACHES_FROM_DICT";
    
    NSDictionary *dbDescription = @{
    cacheName : @{ @"fileName" : @"cachesFileName" }
    };
    
    id< JFFCacheDB > db_ = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription ] cacheByName: cacheName ];
    
    GHAssertTrue( nil != db_                              , @"can't init database with caches" );
    GHAssertTrue( [ cacheName isEqualToString: db_.name ], @"cache db name should be correct" );
    
    NSString* key_           = @"key2";
    NSString* stringToStore_ = @"test Data foo";
    NSData*   dataToStore_   = [ stringToStore_ dataUsingEncoding: NSUTF8StringEncoding ];
    NSDate*   updatedDate_   = nil;
    
    [db_ removeRecordsForKey:key_];
    NSData* storedData_ = [ db_ dataForKey: key_ lastUpdateTime: &updatedDate_ ];

    GHAssertTrue( nil == storedData_ , @"db should be epmty"         );
    GHAssertTrue( nil == updatedDate_, @"updated date should be nil" );
    
    //-------------- set Data
    
    [ db_ setData: dataToStore_
           forKey: key_ ];
    
    //-------------- read with updated data
    
    storedData_ = [ db_ dataForKey: key_ lastUpdateTime: &updatedDate_ ];
    
    NSString* storedString = [ [ NSString alloc ] initWithData: storedData_ encoding: NSUTF8StringEncoding ];
    
    GHAssertTrue( nil != storedData_                              , @"stored data should not be nil"            );
    GHAssertTrue( [ storedString isEqualToString: stringToStore_ ], @"stored and readed string should be equal" );
    
    //-------------- read without updated data
    
    storedData_ = [ db_ dataForKey: key_ ];
    
    storedString = [ [ NSString alloc ] initWithData: storedData_ encoding: NSUTF8StringEncoding ];
    
    GHAssertTrue( nil != storedData_                              , @"stored data should not be nil 1"            );
    GHAssertTrue( [ storedString isEqualToString: stringToStore_ ], @"stored and readed string should be equal 1" );
    
    //-------------- remove records
    
    [ db_ removeRecordsForKey: key_ ];
    
    storedData_ = [ db_ dataForKey: key_ ];
    
    storedString = [ [ NSString alloc ] initWithData: storedData_ encoding: NSUTF8StringEncoding ];
    
    GHAssertTrue( nil == storedData_                                , @"stored data should be nil 1"            );
    GHAssertTrue( ! [ storedString isEqualToString: stringToStore_ ], @"stored and readed string should not be equal" );
}

@end