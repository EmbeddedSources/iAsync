
#import <JFFCache/JFFCache.h>

@interface JFFCachesTest : GHTestCase
@end

@implementation JFFCachesTest

- (void)testJFFCaches
{
    NSString *cacheName = @"URL_CACHES";
    
    id <JFFCacheDB> db = [[JFFCaches sharedCaches] cacheByName:cacheName];
    
    GHAssertTrue(nil != db                          , @"can't init database with caches");
    //GHAssertTrue([cacheName isEqualToString:db.name], @"cache db name should be correct");
    
    NSString *key           = @"key1";
    NSString *stringToStore = @"test Data";
    NSData   *dataToStore   = [stringToStore dataUsingEncoding:NSUTF8StringEncoding];
    NSDate   *updatedDate   = nil;
    
    NSData *storedData = [db dataForKey:key lastUpdateTime:&updatedDate];
    
    GHAssertTrue(nil == storedData , @"db should be epmty"        );
    GHAssertTrue(nil == updatedDate, @"updated date should be nil");
    
    //-------------- set Data
    
    [db setData:dataToStore forKey:key];
    
    //-------------- read with updated data
    
    storedData = [db dataForKey:key lastUpdateTime:&updatedDate];
    
    NSString *storedString = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];
    
    GHAssertTrue(nil != storedData                           , @"stored data should not be nil"           );
    GHAssertTrue([storedString isEqualToString:stringToStore], @"stored and readed string should be equal");
    
    //-------------- read without updated data
    
    storedData = [db dataForKey:key];
    
    storedString = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];
    
    GHAssertTrue(nil != storedData                           , @"stored data should not be nil 1"           );
    GHAssertTrue([storedString isEqualToString:stringToStore], @"stored and readed string should be equal 1");
    
    //-------------- remove records
    
    [db removeRecordsForKey:key];
    
    storedData = [db dataForKey:key];
    
    storedString = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];
    
    GHAssertTrue(nil == storedData                             , @"stored data should be nil 1"                 );
    GHAssertTrue(![ storedString isEqualToString:stringToStore], @"stored and readed string should not be equal");
}

- (void)testJFFCachesWithDBDiscriptionDictionary
{
    NSString *cacheName = @"URL_CACHES_FROM_DICT";
    
    NSDictionary *dbDescription = @{
    cacheName : @{ @"fileName" : @"cachesFileName" }
    };
    
    id <JFFCacheDB> db = [[[JFFCaches alloc] initWithDBInfoDictionary:dbDescription] cacheByName:cacheName];
    
    GHAssertTrue(nil != db                          , @"can't init database with caches");
    //GHAssertTrue([cacheName isEqualToString:db.name], @"cache db name should be correct");
    
    NSString *key           = @"key2";
    NSString *stringToStore = @"test Data foo";
    NSData   *dataToStore_  = [ stringToStore dataUsingEncoding: NSUTF8StringEncoding ];
    NSDate   *updatedDate_  = nil;
    
    [db removeRecordsForKey:key];
    NSData* storedData = [ db dataForKey: key lastUpdateTime: &updatedDate_ ];

    GHAssertTrue( nil == storedData , @"db should be epmty"         );
    GHAssertTrue( nil == updatedDate_, @"updated date should be nil" );
    
    //-------------- set Data
    
    [ db setData: dataToStore_
           forKey: key ];
    
    //-------------- read with updated data
    
    storedData = [ db dataForKey: key lastUpdateTime: &updatedDate_ ];
    
    NSString *storedString = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];
    
    GHAssertTrue(nil != storedData                              , @"stored data should not be nil"          );
    GHAssertTrue([storedString isEqualToString: stringToStore ], @"stored and readed string should be equal");
    
    //-------------- read without updated data
    
    storedData = [db dataForKey:key];
    
    storedString = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];
    
    GHAssertTrue(nil != storedData                           , @"stored data should not be nil 1"           );
    GHAssertTrue([storedString isEqualToString:stringToStore], @"stored and readed string should be equal 1");
    
    //-------------- remove records
    
    [db removeRecordsForKey:key];
    
    storedData = [db dataForKey:key];
    
    storedString = [[NSString alloc] initWithData:storedData encoding:NSUTF8StringEncoding];
    
    GHAssertTrue(nil == storedData                           , @"stored data should be nil 1"                 );
    GHAssertTrue(![storedString isEqualToString:stringToStore], @"stored and readed string should not be equal");
}

@end
