#import "JFFSmartUrlDataLoader.h"

#import "JFFRestKitError.h"

#include <assert.h>

@implementation NSObject (JFFSmartDataLoaderLogResponse)

- (void)logResponse
{
    NSLog( @"jsResponse: %@", self );
}

@end

@implementation NSData (JFFSmartDataLoaderLogResponse)

- (void)logResponse
{
    NSString *str = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    NSLog(@"jsResponse: %@ length: %d", str, self.length);
}

@end

@implementation JFFSmartUrlDataLoaderFields
@end

@implementation JFFResponseDataWithUpdateData

- (id)copyWithZone:(NSZone *)zone
{
    JFFResponseDataWithUpdateData *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_data       = [self->_data       copyWithZone:zone];
        copy->_updateDate = [self->_updateDate copyWithZone:zone];
    }
    
    return copy;
}

@end

@interface JFFErrorNoFreshData : JFFError

@property (nonatomic) id<JFFRestKitCachedData> cachedData;

@end

@implementation JFFErrorNoFreshData

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.rest_kit_internal.library";
}

- (id)init
{
    return [self initWithDescription:@"internal logic error (no fresh data)"];
}

- (id)copyWithZone:(NSZone *)zone
{
    JFFErrorNoFreshData *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_cachedData = [self->_cachedData copyWithZone:zone];
    }
    
    return copy;
}

@end

static JFFAsyncOperationBinder dataLoaderWithCachedResultBinder(BOOL doesNotIgnoreFreshDataLoadFail,
                                                                JFFAsyncOperationBinder dataLoaderForURL,
                                                                NSURL *url)
{
    dataLoaderForURL = [dataLoaderForURL copy];
    return ^JFFAsyncOperation(JFFErrorNoFreshData *noFreshDataError) {
    
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(NSData* srvResponse,
                                                              NSError* error,
                                                              JFFDidFinishAsyncOperationHandler doneCallback) {
            if (!doneCallback)
                return;
            
            //logs [ srvResponse_ logResponse ];
            
            if (srvResponse) {
                JFFResponseDataWithUpdateData *newResult = [JFFResponseDataWithUpdateData new];
                newResult.data = srvResponse;
                doneCallback(newResult, nil);
                return;
            }
            
            if (noFreshDataError.cachedData && !doesNotIgnoreFreshDataLoadFail) {
                JFFResponseDataWithUpdateData *newResult = [JFFResponseDataWithUpdateData new];
                newResult.updateDate = [noFreshDataError.cachedData updateDate];
                newResult.data       = [noFreshDataError.cachedData data];
                doneCallback(newResult, nil);
                return;
            }
            
            doneCallback(nil, error);
        };
        return asyncOperationWithFinishHookBlock(dataLoaderForURL(url),
                                                 finishCallbackHook);
    };
};

static JFFAsyncOperation loadFreshCachedDataWithUpdateDate(id key,
                                                           JFFAsyncOperation cahcedDataLoader,
                                                           JFFCacheLastUpdateDateForKey lastUpdateDateForKey,
                                                           NSTimeInterval cacheDataLifeTime)
{
    JFFAsyncOperationBinder changeCachedDateBinder = ^JFFAsyncOperation(id<JFFRestKitCachedData> cachedData) {
        
        if (lastUpdateDateForKey) {
            JFFAsyncOperationBinder binder = ^JFFAsyncOperation(NSDate *date) {
                JFFResponseDataWithUpdateData *result = [JFFResponseDataWithUpdateData new];
                result.data       = cachedData.data;
                result.updateDate = date?:cachedData.updateDate;
                return asyncOperationWithResult(result);
            };
            
            return bindSequenceOfAsyncOperations(lastUpdateDateForKey(key), binder, nil);
        }
        
        return asyncOperationWithResult(cachedData);
    };
    
    JFFAsyncOperationBinder validateByDateResultBinder = ^JFFAsyncOperation(id<JFFRestKitCachedData> cachedData) {
        
        NSDate *newDate = [cachedData.updateDate dateByAddingTimeInterval:cacheDataLifeTime];
        if ([newDate compare:[NSDate new]] == NSOrderedDescending) {
            return asyncOperationWithResult(cachedData);
        }
        
        JFFErrorNoFreshData *error = [JFFErrorNoFreshData new];
        error.cachedData = cachedData;
        return asyncOperationWithError(error);
    };
    
    return bindSequenceOfAsyncOperations(cahcedDataLoader,
                                         changeCachedDateBinder,
                                         validateByDateResultBinder,
                                         nil);
}

JFFAsyncOperation jSmartDataLoaderWithCache(JFFSmartUrlDataLoaderFields *args)
{
    JFFURLBuilderBinder urlBuilder                    = args.urlBuilder;
    JFFAsyncOperationBinder dataLoaderForURL          = args.dataLoaderForURL;
    JFFAsyncBinderForURL analyzerForData              = args.analyzerForData;
    id< JFFRestKitCache > cache                       = args.cache;
    JFFCacheKeyForURLBuilder cacheKeyForURL           = args.cacheKeyForURL;
    JFFCacheLastUpdateDateForKey lastUpdateDateForKey = args.lastUpdateDateForKey;
    NSTimeInterval cacheDataLifeTime                  = args.cacheDataLifeTime;
    BOOL doesNotIgnoreFreshDataLoadFail               = args.doesNotIgnoreFreshDataLoadFail;
    
    assert(urlBuilder      );//should not be nil
    assert(dataLoaderForURL);//should not be nil
    
    if (!analyzerForData) {
        analyzerForData = ^JFFAsyncOperationBinder(NSURL *url) {
            JFFAnalyzer analyzer = ^id(NSData *data, NSError *__autoreleasing *outError) {
                return data;
            };
            return asyncOperationBinderWithAnalyzer(analyzer);
        };
    }
    
    NSURL *url = urlBuilder();
    
    if (!url) {
        return asyncOperationWithError([JFFRestKitNoURLError new]);
    }
    
    id key;
    if (cache) {
        key = cacheKeyForURL
            ? cacheKeyForURL(url)
            : [url description];
    }
    
    JFFAsyncOperation urlLoader = asyncOperationWithResult(url);
    
    JFFAsyncOperationBinder cachedDataLoaderForURL = ^JFFAsyncOperation(NSURL *url) {
        
        JFFAsyncOperationBinder dataLoaderBinder = dataLoaderWithCachedResultBinder(doesNotIgnoreFreshDataLoadFail,
                                                                                    dataLoaderForURL,
                                                                                    url);
        if (!cache) {
            return dataLoaderBinder(nil);
        }
        JFFAsyncOperation loadChachedData = loadFreshCachedDataWithUpdateDate(key,
                                                                              [cache cachedDataLoaderForKey:key],
                                                                              lastUpdateDateForKey,
                                                                              cacheDataLifeTime);
        
        return bindTrySequenceOfAsyncOperations(loadChachedData, dataLoaderBinder, nil);
    };
    
    JFFAsyncOperationBinder analizer = ^JFFAsyncOperation(JFFResponseDataWithUpdateData *response) {
        
        JFFAsyncOperationBinder binder = analyzerForData(url);
        JFFAsyncOperation analyzer = binder(response.data);
        
        JFFAsyncOperationBinder cacheBinder = ^JFFAsyncOperation(id analizedData) {
            
            JFFAsyncOperation resultLoader = asyncOperationWithResult(analizedData);
            
            if (!response.updateDate) {
                JFFAsyncOperation loader = [cache loaderToSetData:response.data forKey:key];
                return sequenceOfAsyncOperations(loader, resultLoader, nil);
            }
            return resultLoader;
        };
        
        return bindSequenceOfAsyncOperations(analyzer,
                                             cache?cacheBinder:nil,
                                             nil);
    };
    
    return bindSequenceOfAsyncOperations(urlLoader,
                                         cachedDataLoaderForURL,
                                         analizer,
                                         nil);
}

JFFAsyncOperation jSmartDataLoader(NSURL*(^urlBuilder)(void),
                                   JFFAsyncOperationBinder dataLoaderForURL,
                                   JFFAsyncBinderForURL analyzerForData)
{
    JFFSmartUrlDataLoaderFields *args = [JFFSmartUrlDataLoaderFields new];
    args.urlBuilder       = urlBuilder;
    args.dataLoaderForURL = dataLoaderForURL;
    args.analyzerForData  = analyzerForData;
    
    return jSmartDataLoaderWithCache(args);
}
