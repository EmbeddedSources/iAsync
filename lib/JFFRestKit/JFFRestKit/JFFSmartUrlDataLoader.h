#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFRestKit/JFFRestKitCache.h>

#import <Foundation/Foundation.h>

@protocol JFFRestKitCache;

typedef id(^JFFURLBuilderBinder)(void);
typedef JFFAsyncOperationBinder(^JFFAsyncBinderForURL)(NSURL *);
typedef id (^JFFCacheKeyForURLBuilder)(NSURL *);
typedef JFFAsyncOperation(^JFFCacheLastUpdateDateForKey)(id key);

@interface JFFSmartUrlDataLoaderFields : NSObject

@property (nonatomic, copy) JFFURLBuilderBinder urlBuilder;
@property (nonatomic, copy) JFFAsyncOperationBinder dataLoaderForURL;
@property (nonatomic, copy) JFFAsyncBinderForURL analyzerForData;
@property (nonatomic, copy) JFFCacheKeyForURLBuilder cacheKeyForURL;
@property (nonatomic, copy) JFFCacheLastUpdateDateForKey lastUpdateDateForKey;
@property (nonatomic) BOOL doesNotIgnoreFreshDataLoadFail;
@property (nonatomic) id< JFFRestKitCache > cache;
@property (nonatomic) NSTimeInterval cacheDataLifeTime;

@end

//TODO move to JFFRestKitCache.h file
@interface JFFResponseDataWithUpdateData : NSObject <JFFRestKitCachedData>

@property (nonatomic) NSData *data;
@property (nonatomic) NSDate *updateDate;

@end

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation jSmartDataLoaderWithCache(JFFSmartUrlDataLoaderFields *args);
    
    JFFAsyncOperation jSmartDataLoader(NSURL*(^urlBuilder)(void),
                                       JFFAsyncOperationBinder dataLoaderForURL,
                                       JFFAsyncBinderForURL analyzerForData);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
