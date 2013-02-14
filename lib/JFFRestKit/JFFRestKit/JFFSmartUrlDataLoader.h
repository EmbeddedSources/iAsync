#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFRestKit/JFFRestKitCache.h>

#import <Foundation/Foundation.h>

@protocol JFFRestKitCache;

typedef JFFAsyncOperationBinder(^JFFAsyncBinderForIdentifier)(id<NSCopying> loadDataIdentifier);
typedef id (^JFFCacheKeyForIdentifier)(id<NSCopying> loadDataIdentifier);
typedef JFFAsyncOperation(^JFFCacheLastUpdateDateForKey)(id key);

@interface JFFSmartUrlDataLoaderFields : NSObject

@property (nonatomic, copy) id<NSCopying> loadDataIdentifier;
@property (nonatomic, copy) JFFAsyncOperationBinder dataLoaderForIdentifier;
@property (nonatomic, copy) JFFAsyncBinderForIdentifier analyzerForData;
@property (nonatomic, copy) JFFCacheKeyForIdentifier cacheKeyForIdentifier;
@property (nonatomic, copy) JFFCacheLastUpdateDateForKey lastUpdateDateForKey;
@property (nonatomic) BOOL doesNotIgnoreFreshDataLoadFail;
@property (nonatomic) id< JFFRestKitCache > cache;
@property (nonatomic) NSTimeInterval cacheDataLifeTimeInSeconds;

@end

#ifdef __cplusplus
extern "C" {
#endif

    JFFAsyncOperation jSmartDataLoaderWithCache(JFFSmartUrlDataLoaderFields *args);
    
    JFFAsyncOperation jSmartDataLoader(id<NSCopying> loadDataIdentifier,
                                       JFFAsyncOperationBinder dataLoaderForIdentifier,
                                       JFFAsyncBinderForIdentifier analyzerForData);

#ifdef __cplusplus
} /* closing brace for extern "C" */
#endif
