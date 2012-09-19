#import "JFFSmartUrlDataLoader.h"

#import "JFFRestKitError.h"

#include <assert.h>

@implementation NSObject (JFFSmartDataLoaderLogResponse)

-(void)logResponse
{
    NSLog( @"jsResponse: %@", self );
}

@end

@implementation NSData (JFFSmartDataLoaderLogResponse)

-(void)logResponse
{
    NSString* str_ = [ [ NSString alloc ] initWithData: self encoding: NSUTF8StringEncoding ];
    NSLog( @"jsResponse: %@ length: %d", str_, self.length );
}

@end

@implementation JFFSmartUrlDataLoaderFields
@end

@interface JFFResponseDataWithUpdateData : NSObject

@property (nonatomic) NSData *data;
@property (nonatomic) NSDate *updateDate;

@end

@implementation JFFResponseDataWithUpdateData
@end

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
    
    if (!analyzerForData)
    {
        analyzerForData = ^JFFAsyncOperationBinder(NSURL *url)
        {
            JFFAnalyzer analyzer = ^id(NSData *data, NSError *__autoreleasing *outError)
            {
                return data;
            };
            return asyncOperationBinderWithAnalyzer(analyzer);
        };
    }
    
    NSURL *url = urlBuilder();
    
    if (!url)
    {
        return asyncOperationWithError([JFFRestKitNoURLError new]);
    }
    
    id key;
    if (cache)
    {
        key = cacheKeyForURL
            ? cacheKeyForURL(url)
            : [url description];
    }
    
    JFFAsyncOperation urlLoader = asyncOperationWithResult(url);
    
    JFFAsyncOperationBinder cachedDataLoaderForURL =
    ^JFFAsyncOperation(NSURL *url)
    {
        NSDate *lastUpdateDate;
        NSData *cachedData;
        if (lastUpdateDateForKey)
        {
            lastUpdateDate = lastUpdateDateForKey(key);
            cachedData = [cache dataForKey:key
                            lastUpdateDate:NULL];
        }
        else
        {
            cachedData = [cache dataForKey:key
                            lastUpdateDate:&lastUpdateDate];
        }
        
        if (cachedData)
        {
            NSDate *newDate = [lastUpdateDate dateByAddingTimeInterval:cacheDataLifeTime];
            if ([newDate compare:[NSDate new]] == NSOrderedDescending)
            {
                JFFResponseDataWithUpdateData *result = [JFFResponseDataWithUpdateData new];
                result.updateDate = lastUpdateDate;
                result.data       = cachedData;
                return asyncOperationWithResult(result);
            }
        }
        
        JFFDidFinishAsyncOperationHook finishCallbackHook = ^(NSData* srvResponse,
                                                              NSError* error,
                                                              JFFDidFinishAsyncOperationHandler doneCallback)
        {
            if (!doneCallback)
                return;
            
            //logs [ srvResponse_ logResponse ];
            
            if (srvResponse)
            {
                JFFResponseDataWithUpdateData *newResult = [JFFResponseDataWithUpdateData new];
                newResult.data = srvResponse;
                doneCallback(newResult, nil);
                return;
            }
            
            if (cachedData && !doesNotIgnoreFreshDataLoadFail)
            {
                JFFResponseDataWithUpdateData *newResult = [JFFResponseDataWithUpdateData new];
                newResult.updateDate = lastUpdateDate;
                newResult.data       = cachedData;
                doneCallback(newResult, nil);
                return;
            }
            
            doneCallback(nil, error);
        };
        return asyncOperationWithFinishHookBlock(dataLoaderForURL(url),
                                                 finishCallbackHook);
    };
    
    JFFAsyncOperationBinder analizer = ^JFFAsyncOperation(JFFResponseDataWithUpdateData *response)
    {
        JFFAsyncOperationBinder binder = analyzerForData(url);
        JFFAsyncOperation analyzer = binder(response.data);
        
        JFFAsyncOperationBinder cacheBinder = ^JFFAsyncOperation(id analizedData)
        {
            if (!response.updateDate)
            {
                [cache setData:response.data
                        forKey:key];
            }
            return asyncOperationWithResult(analizedData);
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
