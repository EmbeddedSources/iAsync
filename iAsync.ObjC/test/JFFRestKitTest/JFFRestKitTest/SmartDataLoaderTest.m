
#import <JFFRestKit/Details/JFFResponseDataWithUpdateData.h>

static NSString* const globalCachesFileName = @"cachesFileName";

@interface CacheDBAdaptor : NSObject <JFFRestKitCache>

@property (nonatomic) id<JFFCacheDB> jffCacheDB;

@end

@implementation CacheDBAdaptor

@synthesize jffCacheDB;

- (JFFAsyncOperation)loaderToSetData:(NSData *)data forKey:(NSString *)key
{
    [jffCacheDB setData:data forKey:key];
    return asyncOperationWithResult([NSNull new]);
}

- (JFFAsyncOperation)cachedDataLoaderForKey:(NSString *)key
{
    NSDate *date;
    
    NSData *data = [jffCacheDB dataForKey:key lastUpdateTime:&date];
    
    if (data) {
        JFFResponseDataWithUpdateData *result = [JFFResponseDataWithUpdateData new];
        result.data       = data;
        result.updateDate = date;
        return asyncOperationWithResult(result);
    }
    
    return asyncOperationWithError([JFFError newErrorWithDescription:@"no data"]);
}

@end

@interface SmartDataLoaderTest : GHAsyncTestCase
@end

static JFFAsyncOperationBinder testDataLoader(BOOL *wasCalled)
{
    return ^JFFAsyncOperation(NSURL *url) {
        NSData *response = [[url description] dataUsingEncoding:NSUTF8StringEncoding];
        return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                         JFFAsyncOperationChangeStateCallback cancelCallback,
                                         JFFDidFinishAsyncOperationCallback doneCallback) {
            if (wasCalled)
                *wasCalled = YES;
            return asyncOperationWithResult(response)(progressCallback,
                                                      cancelCallback,
                                                      doneCallback);
        };
    };
}

static JFFAsyncOperationBinder badTestDataLoader()
{
    return ^JFFAsyncOperation(NSURL *url) {
        return asyncOperationWithError([JFFError newErrorWithDescription:@"test error"]);
    };
}

static NSString const* differntServerResponse = @"differnt response";

static JFFAsyncOperationBinder differentTestDataLoader(BOOL *wasCalled)
{
    return ^JFFAsyncOperation(NSURL *url) {
        
        NSData *response = [differntServerResponse  dataUsingEncoding:NSUTF8StringEncoding];
        return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                         JFFAsyncOperationChangeStateCallback cancelCallback,
                                         JFFDidFinishAsyncOperationCallback doneCallback) {
            
            if (wasCalled)
                *wasCalled = YES;
            return asyncOperationWithResult(response)(progressCallback,
                                                      cancelCallback,
                                                      doneCallback);
        };
    };
}

@implementation SmartDataLoaderTest

- (void)tearDown
{
    NSString *path = [NSString documentsPathByAppendingPathComponent:globalCachesFileName];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)testSmartDataLoaderWithoutCache
{
    JFFAsyncOperationBinder dataLoaderForURL = testDataLoader(NULL);
    
    JFFAsyncBinderForIdentifier analyzerForData = ^JFFAsyncOperationBinder(NSURL *url) {
        
        return ^JFFAsyncOperation(NSData *data) {
            
            NSString *str = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
            return asyncOperationWithResult(str);
        };
    };
    
    JFFAsyncOperation loader = jSmartDataLoader([@"http://google.com" toURL],
                                                dataLoaderForURL,
                                                analyzerForData );
    
    __block NSString *result = nil;
    
    loader(nil, nil, ^(id data, NSError *error) {
        result = data;
    });
    
    GHAssertTrue([@"http://google.com" isEqualToString:result], @"OK");
}

//Don't cache response which can not be analyzed
- (void)testDoNotCacheResponseWhichCanNotBeAnalyzed
{
    NSURL *url = [@"http://google.com" toURL];
    
    JFFAsyncOperationBinder dataLoaderForURL = testDataLoader(NULL);
    
    __block NSError *errorToFail = nil;
    
    JFFAsyncBinderForIdentifier analyzerForData = ^JFFAsyncOperationBinder(NSURL *url) {
        return ^JFFAsyncOperation(NSData *data) {
            errorToFail = [JFFError newErrorWithDescription:@"test error"];
            return asyncOperationWithError(errorToFail);
        };
    };
    
    JFFAsyncOperation loader = jSmartDataLoader(url,
                                                dataLoaderForURL,
                                                analyzerForData);
    
    __block NSError *resultError = nil;
    
    loader(nil, nil, ^(id data, NSError *error) {
        
        resultError = error;
    });

    GHAssertTrue( errorToFail == resultError, @"OK" );
}

//Use cached data if cannot load data
-(void)testUseCachedDataIfCannotLoadData
{
    static NSString *const cacheName = @"URL_CACHES_FROM_DICT";
    
    NSDictionary *dbDescription_ = @{ cacheName : @{ @"fileName" : globalCachesFileName } };
    
    CacheDBAdaptor *cache = [CacheDBAdaptor new];
    
    cache.jffCacheDB = [[[JFFCaches alloc] initWithDBInfoDictionary:dbDescription_] cacheByName:cacheName];
    
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    
    JFFAsyncOperationBinder dataLoaderForURL = testDataLoader(NULL);
    
    JFFAsyncBinderForIdentifier analyzerForData = ^JFFAsyncOperationBinder(NSURL *url) {
        
        return ^JFFAsyncOperation(NSData *data) {
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return asyncOperationWithResult(str);
        };
    };
    
    JFFSmartUrlDataLoaderFields *args = [ JFFSmartUrlDataLoaderFields new ];
    args.loadDataIdentifier         = url;
    args.dataLoaderForIdentifier    = dataLoaderForURL;
    args.analyzerForData            = analyzerForData;
    args.cache                      = cache;
    args.cacheDataLifeTimeInSeconds = 5.5;
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache(args);
    
    args.dataLoaderForIdentifier = badTestDataLoader();
    
    JFFAsyncOperation loaderWromCache = jSmartDataLoaderWithCache(args);
    __block NSString *storedDataString = nil;
    __block NSString *cachedDataString = nil;
    
    loader(nil, nil, ^(id data, NSError *error) {
        
        storedDataString = data;
        loaderWromCache( nil, nil, ^(id data, NSError *error) {
            cachedDataString = data;
        });
    });
    
    GHAssertEqualObjects(cachedDataString, storedDataString, @"cached and stored data should be same");
}

//Try load data if cache data old
- (void)testTryLoadDataIfCacheDataOld
{
    NSString *cacheName = @"URL_CACHES_FROM_DICT1";
    
    NSDictionary *dbDescription_ = @{ cacheName : @{ @"fileName" : globalCachesFileName } };
    
    CacheDBAdaptor *cache = [CacheDBAdaptor new];
    
    cache.jffCacheDB = [[[JFFCaches alloc] initWithDBInfoDictionary:dbDescription_] cacheByName:cacheName];
    
    NSURL *url = [NSURL URLWithString:@"http://google.com"];
    
    JFFAsyncOperationBinder dataLoaderForURL = testDataLoader( NULL );
    
    JFFAsyncBinderForIdentifier analyzerForData = ^JFFAsyncOperationBinder(NSURL *url) {
        return ^JFFAsyncOperation(NSData *data) {
            NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return asyncOperationWithResult(resp);
        };
    };
    
    JFFSmartUrlDataLoaderFields *args = [JFFSmartUrlDataLoaderFields new];
    args.loadDataIdentifier         = url;
    args.dataLoaderForIdentifier    = dataLoaderForURL;
    args.analyzerForData            = analyzerForData;
    args.cache                      = cache;
    args.cacheDataLifeTimeInSeconds = 5000.5;
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache(args);
    
    args.dataLoaderForIdentifier = badTestDataLoader();
    args.cacheDataLifeTimeInSeconds = -5000.5;
    
    JFFAsyncOperation loaderWromCache = jSmartDataLoaderWithCache(args);
    
    __block NSString *storedDataString;
    __block NSString *cachedDataString;
    
    loader(nil, nil, ^(id data, NSError *error) {
        
        storedDataString = data;
        loaderWromCache( nil, nil, ^(id data, NSError *error) {
            cachedDataString = data;
        });
    });
    
    GHAssertEqualObjects(cachedDataString, storedDataString, @"cached and stored data should be same");
}

//Use cached data if cache data is fresh
- (void)testUseCachedDataIfCacheDataIsFresh
{
    NSString *cacheName = @"URL_CACHES_FROM_DICT2";
    
    NSDictionary *dbDescription_ = @{ cacheName : @{ @"fileName": globalCachesFileName } };
    
    CacheDBAdaptor *cache_ = [CacheDBAdaptor new];
    
    id <JFFCacheDB> jffCache = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName ];
    cache_.jffCacheDB = jffCache;
    
    NSURL *url_ = [@"http://google.com" toURL];
    
    BOOL wasCalled = NO;
    
    JFFAsyncBinderForIdentifier analyzerForData = ^JFFAsyncOperationBinder(NSURL *url_)
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* str_ = [ [ NSString alloc ] initWithData: data_ encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( str_ );
        };
    };
    
    JFFSmartUrlDataLoaderFields *args_ = [JFFSmartUrlDataLoaderFields new];
    args_.loadDataIdentifier         = url_;
    args_.dataLoaderForIdentifier    = testDataLoader( &wasCalled );
    args_.analyzerForData            = analyzerForData;
    args_.cache                      = cache_;
    args_.cacheDataLifeTimeInSeconds = 5.5;
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache( args_ );

    BOOL wasCalledAgain_ = NO;

    args_.dataLoaderForIdentifier = differentTestDataLoader( &wasCalledAgain_ );

    JFFAsyncOperation differentLoader = jSmartDataLoaderWithCache( args_ );

    __block NSString* storedDataString_ = nil;
    __block NSString* cachedDataString_ = nil;

    loader( nil, nil, ^(id data, NSError *error) {
        
        storedDataString_ = data;
        differentLoader( nil, nil, ^(id data, NSError *error) {
            
            cachedDataString_ = data;
        });
    });
    
    GHAssertTrue([cachedDataString_ isEqualToString:storedDataString_],
                 @"cached and stored data should be same");

    GHAssertTrue (wasCalled, @"OK" );
    GHAssertFalse(wasCalledAgain_, @"OK" );
}

@end
