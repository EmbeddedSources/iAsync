
static NSString* const cachesFileName_ = @"cachesFileName";

@interface CacheDBAdaptor : NSObject < JFFRestKitCache >

@property ( nonatomic, strong ) id< JFFCacheDB >  jffCacheDB;

@end

@implementation CacheDBAdaptor

@synthesize jffCacheDB;

-(void)setData:( NSData* )data_ forKey:( NSString* )key_
{
    [ jffCacheDB setData: data_ forKey: key_ ];
}

-(NSData*)dataForKey:( NSString* )data_ lastUpdateDate:( NSDate** )date_
{
    return  [ jffCacheDB dataForKey: data_ lastUpdateTime: date_ ];
}

@end

@interface SmartDataLoaderTest : GHTestCase
@end

static JFFAsyncOperationBinder testDataLoader( BOOL* wasCalled_ )
{
    return ^JFFAsyncOperation( NSURL* url_ )
    {
        NSData* response_ = [ [ url_ description ] dataUsingEncoding: NSUTF8StringEncoding ];
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

static JFFAsyncOperationBinder badTestDataLoader()
{
    return ^JFFAsyncOperation( NSURL* url_ )
    {
        return asyncOperationWithError( [ JFFError newErrorWithDescription: @"test error" ] );
    };
}

static NSString* differntServerResponse_ = @"differnt response";

static JFFAsyncOperationBinder differentTestDataLoader( BOOL* wasCalled_ )
{
    return ^JFFAsyncOperation( NSURL* url_ )
    {
        NSData* response_ = [ differntServerResponse_  dataUsingEncoding: NSUTF8StringEncoding ];
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
    NSString* path_ = [ NSString documentsPathByAppendingPathComponent: cachesFileName_ ];
    [ [ NSFileManager defaultManager ] removeItemAtPath: path_ error: nil ];
}

// @"/sitecore"
-(void)testSmartDataLoaderWithoutCache
{
    NSURL*(^urlBuilder_)(void) = ^NSURL*()
    {
        return [ NSURL URLWithString: @"http://google.com" ];
    };

    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );

    JFFAsyncBinderForURL analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* str_ = [ [ NSString alloc ] initWithData: data_
                                                      encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( str_ );
        };
    };

    JFFAsyncOperation loader_ = jSmartDataLoader( urlBuilder_
                                                 , dataLoaderForURL_
                                                 , analyzerForData_ );

    __block NSString* result_ = nil;

    loader_( nil, nil, ^( id data_, NSError* error_ )
    {
        result_ = data_;
    } );

    GHAssertTrue( [ @"http://google.com" isEqualToString: result_ ], @"OK" );
}

//Don't cache response which can not be analyzed
-(void)testDoNotCacheResponseWhichCanNotBeAnalyzed
{
    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    NSURL*(^urlBuilder_)(void) = ^NSURL*()
    {
        return url_;
    };

    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );

    __block NSError* errorToFail_ = nil;

    JFFAsyncBinderForURL analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            errorToFail_ = [ JFFError newErrorWithDescription: @"test error" ];
            return asyncOperationWithError( errorToFail_ );
        };
    };

    JFFAsyncOperation loader_ = jSmartDataLoader( urlBuilder_
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
-(void)testUseCachedDataIfCannotLoadData
{
    static NSString* const cacheName_ = @"URL_CACHES_FROM_DICT";

    NSDictionary* dbDescription_ = @{ cacheName_ : @{ @"fileName" : cachesFileName_ } };

    CacheDBAdaptor* cache_ = [ CacheDBAdaptor new ];

    cache_.jffCacheDB = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName_ ];

    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    NSURL*(^urlBuilder_)(void) = ^NSURL*()
    {
        return url_;
    };

    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );

    JFFAsyncBinderForURL analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* str_ = [ [ NSString alloc ] initWithData: data_ encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( str_ );
        };
    };

    JFFSmartUrlDataLoaderFields* args_ = [ JFFSmartUrlDataLoaderFields new ];
    args_.urlBuilder        = urlBuilder_;
    args_.dataLoaderForURL  = dataLoaderForURL_;
    args_.analyzerForData   = analyzerForData_;
    args_.cache             = cache_;
    args_.cacheDataLifeTime = 5.5;

    JFFAsyncOperation loader_ = jSmartDataLoaderWithCache( args_ );

    args_.dataLoaderForURL = badTestDataLoader();

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

    NSDictionary* dbDescription_ = @{ cacheName_ : @{ @"fileName" : cachesFileName_ } };

    CacheDBAdaptor* cache_ = [ CacheDBAdaptor new ];

    cache_.jffCacheDB = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName_ ];

    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    NSURL*(^urlBuilder_)(void) = ^NSURL*()
    {
        return url_;
    };

    JFFAsyncOperationBinder dataLoaderForURL_ = testDataLoader( NULL );

    JFFAsyncBinderForURL analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* resp_ = [ [ NSString alloc ] initWithData: data_ encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( resp_ );
        };
    };

    JFFSmartUrlDataLoaderFields* args_ = [ JFFSmartUrlDataLoaderFields new ];
    args_.urlBuilder        = urlBuilder_;
    args_.dataLoaderForURL  = dataLoaderForURL_;
    args_.analyzerForData   = analyzerForData_;
    args_.cache             = cache_;
    args_.cacheDataLifeTime = 5.5;

    JFFAsyncOperation loader_ = jSmartDataLoaderWithCache( args_ );

    args_.dataLoaderForURL  = badTestDataLoader();
    args_.cacheDataLifeTime = -5.5;

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

//Use cached data if cache data is fresh
-(void)testUseCachedDataIfCacheDataIsFresh
{
    NSString* cacheName_ = @"URL_CACHES_FROM_DICT2";

    NSDictionary* dbDescription_ = @{ cacheName_: @{ @"fileName": cachesFileName_ } };

    CacheDBAdaptor* cache_ = [ CacheDBAdaptor new ];

    id< JFFCacheDB > jffCache_ = [ [ [ JFFCaches alloc ] initWithDBInfoDictionary: dbDescription_ ] cacheByName: cacheName_ ];
    cache_.jffCacheDB = jffCache_;

    NSURL* url_ = [ NSURL URLWithString: @"http://google.com" ];
    NSURL*(^urlBuilder_)(void) = ^NSURL*()
    {
        return url_;
    };

    BOOL wasCalled_ = NO;

    JFFAsyncBinderForURL analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
    {
        return ^JFFAsyncOperation( NSData* data_ )
        {
            NSString* str_ = [ [ NSString alloc ] initWithData: data_ encoding: NSUTF8StringEncoding ];
            return asyncOperationWithResult( str_ );
        };
    };

    JFFSmartUrlDataLoaderFields* args_ = [ JFFSmartUrlDataLoaderFields new ];
    args_.urlBuilder        = urlBuilder_;
    args_.dataLoaderForURL  = testDataLoader( &wasCalled_ );
    args_.analyzerForData   = analyzerForData_;
    args_.cache             = cache_;
    args_.cacheDataLifeTime = 5.5;

    JFFAsyncOperation loader_ = jSmartDataLoaderWithCache( args_ );

    BOOL wasCalledAgain_ = NO;

    args_.dataLoaderForURL  = differentTestDataLoader( &wasCalledAgain_ );

    JFFAsyncOperation differentLoader_ = jSmartDataLoaderWithCache( args_ );

    __block NSString* storedDataString_ = nil;
    __block NSString* cachedDataString_ = nil;

    loader_( nil, nil, ^( id data_, NSError* error_ )
    {
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
