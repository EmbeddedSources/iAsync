#import <Foundation/Foundation.h>

@protocol JFFRestKitCache;

typedef JFFAsyncOperationBinder(^JFFAsyncBinderForURL)( NSURL* );

#import <JFFRestKit/JFFRestKitCache.h>

JFFAsyncOperation jSmartDataLoaderWithCache( NSURL*(^urlBuilder_)(void)
                                            , JFFAsyncOperationBinder dataLoaderForURL_
                                            , JFFAsyncBinderForURL analyzerForData_
                                            , id< JFFRestKitCache > cache_
                                            , id(^keyForURL_)(NSURL*)
                                            , NSTimeInterval lifeTime_ );

JFFAsyncOperation jSmartDataLoader( NSURL*(^urlBuilder_)(void)
                                   , JFFAsyncOperationBinder dataLoaderForURL_
                                   , JFFAsyncBinderForURL analyzerForData_ );
