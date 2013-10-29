#import "JFFSmartUrlDataLoader.h"

#import "JFFResponseDataWithUpdateData.h"

#import <JFFRestKit/JFFRestKitCache.h>

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
    NSLog(@"jsResponse: %@ length: %lu", str, (unsigned long)self.length);
}

@end

@implementation JFFSmartUrlDataLoaderFields
@end

@interface JFFErrorNoFreshData : JFFError

@property (nonatomic) id<JFFRestKitCachedData> cachedData;

@end

@implementation JFFErrorNoFreshData

+ (NSString *)jffErrorsDomain
{
    return @"com.just_for_fun.rest_kit_internal.library";
}

- (instancetype)init
{
    return [self initWithDescription:@"internal logic error (no fresh data)"];
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFErrorNoFreshData *copy = [super copyWithZone:zone];
    
    if (copy) {
        copy->_cachedData = [_cachedData copyWithZone:zone];
    }
    
    return copy;
}

@end

static JFFAsyncOperationBinder dataLoaderWithCachedResultBinder(BOOL doesNotIgnoreFreshDataLoadFail,
                                                                JFFAsyncOperationBinder dataLoaderForIdentifier,
                                                                id<NSCopying> loadDataIdentifier)
{
    dataLoaderForIdentifier = [dataLoaderForIdentifier copy];
    return ^JFFAsyncOperation(NSError *bindError) {
    
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
            
            //TODO test [bindError isKindOfClass:[JFFErrorNoFreshData class]] issue, here it can got - not data in cache error !!!
            JFFErrorNoFreshData *noFreshDataError =
            (JFFErrorNoFreshData *)([bindError isKindOfClass:[JFFErrorNoFreshData class]]?bindError:nil);
            if ([noFreshDataError.cachedData data] && !doesNotIgnoreFreshDataLoadFail) {
                JFFResponseDataWithUpdateData *newResult = [JFFResponseDataWithUpdateData new];
                newResult.updateDate = [noFreshDataError.cachedData updateDate];
                newResult.data       = [noFreshDataError.cachedData data];
                doneCallback(newResult, nil);
                return;
            }
            
            doneCallback(nil, error);
        };
        return asyncOperationWithFinishHookBlock(dataLoaderForIdentifier(loadDataIdentifier),
                                                 finishCallbackHook);
    };
};

static JFFAsyncOperation loadFreshCachedDataWithUpdateDate(id key,
                                                           JFFAsyncOperation cachedDataLoader,
                                                           NSTimeInterval cacheDataLifeTimeInSeconds)
{
    JFFAsyncOperationBinder validateByDateResultBinder = ^JFFAsyncOperation(id<JFFRestKitCachedData> cachedData) {
        
        NSDate *newDate = [cachedData.updateDate dateByAddingTimeInterval:cacheDataLifeTimeInSeconds];
        if ([newDate compare:[NSDate new]] == NSOrderedDescending) {
            return asyncOperationWithResult(cachedData);
        }
        
        JFFErrorNoFreshData *error = [JFFErrorNoFreshData new];
        error.cachedData = cachedData;
        return asyncOperationWithError(error);
    };
    
    return bindSequenceOfAsyncOperations(cachedDataLoader,
                                         validateByDateResultBinder,
                                         nil);
}

JFFAsyncOperation jSmartDataLoaderWithCache(JFFSmartUrlDataLoaderFields *args)
{
    id                          loadDataIdentifier             = args.loadDataIdentifier;
    JFFAsyncOperationBinder     dataLoaderForIdentifier        = args.dataLoaderForIdentifier;
    JFFAsyncBinderForIdentifier analyzerForData                = args.analyzerForData;
    id <JFFRestKitCache>        cache                          = args.cache;
    JFFCacheKeyForIdentifier    cacheKeyForIdentifier          = args.cacheKeyForIdentifier;
    NSTimeInterval              cacheDataLifeTimeInSeconds     = args.cacheDataLifeTimeInSeconds;
    BOOL                        doesNotIgnoreFreshDataLoadFail = args.doesNotIgnoreFreshDataLoadFail;
    
    NSCParameterAssert(loadDataIdentifier     );
    NSCParameterAssert(dataLoaderForIdentifier);
    
    if (!analyzerForData) {
        analyzerForData = ^JFFAsyncOperationBinder(NSURL *url) {
            JFFAnalyzer analyzer = ^id(NSData *data, NSError *__autoreleasing *outError) {
                return data;
            };
            return asyncOperationBinderWithAnalyzer(analyzer);
        };
    }
    
    id key;
    if (cache) {
        key = cacheKeyForIdentifier
            ?cacheKeyForIdentifier(loadDataIdentifier)
            :[loadDataIdentifier description];
    }
    
    JFFAsyncOperation cachedDataLoader = ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                                                  JFFCancelAsyncOperationHandler cancelCallback,
                                                                  JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFAsyncOperationBinder dataLoaderBinder = dataLoaderWithCachedResultBinder(doesNotIgnoreFreshDataLoadFail,
                                                                                    dataLoaderForIdentifier,
                                                                                    loadDataIdentifier);
        
        JFFAsyncOperation loader;
        
        if (!cache) {
            loader = dataLoaderBinder(nil);
        } else {
        
            JFFAsyncOperation loadChachedData = loadFreshCachedDataWithUpdateDate(key,
                                                                                  [cache cachedDataLoaderForKey:key],
                                                                                  cacheDataLifeTimeInSeconds);
            
            loader = bindTrySequenceOfAsyncOperations(loadChachedData, dataLoaderBinder, nil);
        }
        
        return loader(progressCallback,
                      cancelCallback,
                      doneCallback);
    };
    
    JFFAsyncOperationBinder analyzer = ^JFFAsyncOperation(JFFResponseDataWithUpdateData *response) {
        
        JFFAsyncOperationBinder binder = analyzerForData(loadDataIdentifier);
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
    
    return bindSequenceOfAsyncOperations(cachedDataLoader,
                                         analyzer,
                                         nil);
}

JFFAsyncOperation jSmartDataLoader(id<NSCopying> loadDataIdentifier,
                                   JFFAsyncOperationBinder dataLoaderForIdentifier,
                                   JFFAsyncBinderForIdentifier analyzerForData)
{
    JFFSmartUrlDataLoaderFields *args = [JFFSmartUrlDataLoaderFields new];
    args.loadDataIdentifier      = loadDataIdentifier;
    args.dataLoaderForIdentifier = dataLoaderForIdentifier;
    args.analyzerForData         = analyzerForData;
    
    return jSmartDataLoaderWithCache(args);
}
