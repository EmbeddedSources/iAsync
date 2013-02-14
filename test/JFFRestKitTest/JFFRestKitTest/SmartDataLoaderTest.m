
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

static JFFAsyncOperationBinder testDataLoader(BOOL* wasCalled)
{
    return ^JFFAsyncOperation(NSURL *url) {
        NSData *response = [[url description] dataUsingEncoding:NSUTF8StringEncoding];
        return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                        JFFCancelAsyncOperationHandler cancelCallback,
                                        JFFDidFinishAsyncOperationHandler doneCallback) {
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

static JFFAsyncOperationBinder differentTestDataLoader( BOOL* wasCalled_ )
{
    return ^JFFAsyncOperation( NSURL* url_ )
    {
        NSData* response_ = [differntServerResponse  dataUsingEncoding:NSUTF8StringEncoding];
        return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            if ( wasCalled_ )
                *wasCalled_ = YES;
            return asyncOperationWithResult( response_ )( progressCallback_
                                                         , cancelCallback_
                                                         , doneCallback_ );
        };
    };
}

@implementation SmartDataLoaderTest

-(void)tearDown
{
    NSString *path = [NSString documentsPathByAppendingPathComponent:globalCachesFileName];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

// @"/sitecore"
-(void)RtestSmartDataLoaderWithoutCache
{
    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );
    
    JFFAsyncBinderForIdentifier analyzerForData = ^JFFAsyncOperationBinder(NSURL *url_)
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* str_ = [ [ NSString alloc ] initWithData: data_
                                                      encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( str_ );
        };
    };
    
    JFFAsyncOperation loader_ = jSmartDataLoader([NSURL URLWithString: @"http://google.com"],
                                                 dataLoaderForURL_,
                                                 analyzerForData );
    
    __block NSString* result_ = nil;
    
    loader_( nil, nil, ^( id data_, NSError* error_ )
    {
        result_ = data_;
    } );
    
    GHAssertTrue( [ @"http://google.com" isEqualToString: result_ ], @"OK" );
}

//Don't cache response which can not be analyzed
-(void)RtestDoNotCacheResponseWhichCanNotBeAnalyzed
{
    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    
    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );
    
    __block NSError* errorToFail_ = nil;
    
    JFFAsyncBinderForIdentifier analyzerForData_ = ^JFFAsyncOperationBinder(NSURL *url) {
        return ^JFFAsyncOperation(NSData *data) {
            errorToFail_ = [ JFFError newErrorWithDescription: @"test error" ];
            return asyncOperationWithError( errorToFail_ );
        };
    };
    
    JFFAsyncOperation loader_ = jSmartDataLoader( url_
                                                 , dataLoaderForURL_
                                                 , analyzerForData_ );

    __block NSError* resultError_ = nil;

    loader_( nil, nil, ^( id data_, NSError* error_ )
    {
        resultError_ = error_;
    } );

    GHAssertTrue( errorToFail_ == resultError_, @"OK" );
}

//Use cached data if cannot load data
-(void)RtestUseCachedDataIfCannotLoadData
{
    static NSString* const cacheName_ = @"URL_CACHES_FROM_DICT";

    NSDictionary* dbDescription_ = @{ cacheName_ : @{ @"fileName" : globalCachesFileName } };

    CacheDBAdaptor* cache_ = [ CacheDBAdaptor new ];

    cache_.jffCacheDB = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName_ ];

    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    
    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );
    
    JFFAsyncBinderForIdentifier analyzerForData_ = ^JFFAsyncOperationBinder(NSURL *url_) {
        
        return ^JFFAsyncOperation(NSData *data_) {
            
            NSString* str_ = [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding];
            return asyncOperationWithResult( str_ );
        };
    };
    
    JFFSmartUrlDataLoaderFields* args_ = [ JFFSmartUrlDataLoaderFields new ];
    args_.loadDataIdentifier         = url_;
    args_.dataLoaderForIdentifier    = dataLoaderForURL_;
    args_.analyzerForData            = analyzerForData_;
    args_.cache                      = cache_;
    args_.cacheDataLifeTimeInSeconds = 5.5;
    
    JFFAsyncOperation loader_ = jSmartDataLoaderWithCache( args_ );
    
    args_.dataLoaderForIdentifier = badTestDataLoader();
    
    JFFAsyncOperation loaderWromCache_ = jSmartDataLoaderWithCache( args_ );
    __block NSString* storedDataString_ = nil;
    __block NSString* cachedDataString_ = nil;

    loader_( nil, nil, ^( id data_, NSError* error_ )
    {
        storedDataString_ = data_;
        loaderWromCache_( nil, nil, ^( id data_, NSError* error_ )
        {
            cachedDataString_ = data_;
        } );
    } );

    GHAssertEqualObjects( cachedDataString_, storedDataString_, @"cached and stored data should be same" );
}

//Try load data if cache data old
-(void)testTryLoadDataIfCacheDataOld
{
    NSString* cacheName_ = @"URL_CACHES_FROM_DICT1";
    
    NSDictionary* dbDescription_ = @{ cacheName_ : @{ @"fileName" : globalCachesFileName } };
    
    CacheDBAdaptor* cache_ = [ CacheDBAdaptor new ];
    
    cache_.jffCacheDB = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName_ ];
    
    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    
    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );
    
    JFFAsyncBinderForIdentifier analyzerForData_ = ^JFFAsyncOperationBinder(NSURL *url) {
        return ^JFFAsyncOperation(NSData *data) {
            NSString *resp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            return asyncOperationWithResult(resp);
        };
    };

    JFFSmartUrlDataLoaderFields* args_ = [ JFFSmartUrlDataLoaderFields new ];
    args_.loadDataIdentifier         = url_;
    args_.dataLoaderForIdentifier    = dataLoaderForURL_;
    args_.analyzerForData            = analyzerForData_;
    args_.cache                      = cache_;
    args_.cacheDataLifeTimeInSeconds = 5000.5;
    
    JFFAsyncOperation loader_ = jSmartDataLoaderWithCache( args_ );
    
    args_.dataLoaderForIdentifier  = badTestDataLoader();
    args_.cacheDataLifeTimeInSeconds = -5000.5;

    JFFAsyncOperation loaderWromCache_ = jSmartDataLoaderWithCache( args_ );

    __block NSString *storedDataString;
    __block NSString *cachedDataString;
    
    loader_(nil, nil, ^(id data, NSError *error) {
        
        storedDataString = data;
        loaderWromCache_( nil, nil, ^(id data, NSError *error) {
            cachedDataString = data;
        });
    });
    
    GHAssertEqualObjects(cachedDataString, storedDataString, @"cached and stored data should be same");
}

//Use cached data if cache data is fresh
-(void)RtestUseCachedDataIfCacheDataIsFresh
{
    NSString* cacheName_ = @"URL_CACHES_FROM_DICT2";

    NSDictionary* dbDescription_ = @{ cacheName_: @{ @"fileName": globalCachesFileName } };

    CacheDBAdaptor* cache_ = [ CacheDBAdaptor new ];

    id< JFFCacheDB > jffCache_ = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName_ ];
    cache_.jffCacheDB = jffCache_;

    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    
    BOOL wasCalled_ = NO;
    
    JFFAsyncBinderForIdentifier analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* str_ = [ [ NSString alloc ] initWithData: data_ encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( str_ );
        };
    };
    
    JFFSmartUrlDataLoaderFields *args_ = [JFFSmartUrlDataLoaderFields new];
    args_.loadDataIdentifier         = url_;
    args_.dataLoaderForIdentifier    = testDataLoader( &wasCalled_ );
    args_.analyzerForData            = analyzerForData_;
    args_.cache                      = cache_;
    args_.cacheDataLifeTimeInSeconds = 5.5;
    
    JFFAsyncOperation loader = jSmartDataLoaderWithCache( args_ );

    BOOL wasCalledAgain_ = NO;

    args_.dataLoaderForIdentifier = differentTestDataLoader( &wasCalledAgain_ );

    JFFAsyncOperation differentLoader_ = jSmartDataLoaderWithCache( args_ );

    __block NSString* storedDataString_ = nil;
    __block NSString* cachedDataString_ = nil;

    loader( nil, nil, ^( id data_, NSError* error_ ) {
        
        storedDataString_ = data_;
        differentLoader_( nil, nil, ^( id data_, NSError* error_ )
        {
            cachedDataString_ = data_;
        } );
    } );

    GHAssertTrue( [ cachedDataString_ isEqualToString: storedDataString_ ]
                 , @"cached and stored data should be same" );

    GHAssertTrue ( wasCalled_, @"OK" );
    GHAssertFalse( wasCalledAgain_, @"OK" );
}

@end
