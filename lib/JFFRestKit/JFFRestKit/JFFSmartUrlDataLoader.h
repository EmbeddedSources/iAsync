#import <JFFAsyncOperations/JFFAsyncOperationsBlockDefinitions.h>
#import <JFFRestKit/JFFRestKitCache.h>

#import <Foundation/Foundation.h>

@protocol JFFRestKitCache;

typedef id(^JFFURLBuilderBinder)( void );
typedef JFFAsyncOperationBinder(^JFFAsyncBinderForURL)( NSURL* );
typedef id (^JFFCacheKeyForURLBuilder)( NSURL* );

@interface JFFSmartUrlDataLoaderFields : NSObject

@property ( nonatomic, copy   ) JFFURLBuilderBinder urlBuilder;
@property ( nonatomic, copy   ) JFFAsyncOperationBinder dataLoaderForURL;
@property ( nonatomic, copy   ) JFFAsyncBinderForURL analyzerForData;
@property ( nonatomic, strong ) id< JFFRestKitCache > cache;
@property ( nonatomic, copy   ) JFFCacheKeyForURLBuilder cacheKeyForURL;
@property ( nonatomic, assign ) NSTimeInterval cacheDataLifeTime;

@end

JFFAsyncOperation jSmartDataLoaderWithCache( JFFSmartUrlDataLoaderFields* args_ );

JFFAsyncOperation jSmartDataLoader( NSURL*(^urlBuilder_)(void)
                                   , JFFAsyncOperationBinder dataLoaderForURL_
                                   , JFFAsyncBinderForURL analyzerForData_ );
