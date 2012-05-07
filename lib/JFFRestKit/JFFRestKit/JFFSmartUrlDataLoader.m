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

@synthesize urlBuilder
, dataLoaderForURL
, analyzerForData
, cache
, cacheKeyForURL
, cacheDataLifeTime;

@end

@interface JFFResponseDataWithUpdateData : NSObject

@property ( nonatomic ) NSData* data;
@property ( nonatomic ) NSDate* updateDate;

@end

@implementation JFFResponseDataWithUpdateData

@synthesize data       = _data;
@synthesize updateDate = _updateDate;

@end

JFFAsyncOperation jSmartDataLoaderWithCache( JFFSmartUrlDataLoaderFields* args_ )
{
    JFFURLBuilderBinder urlBuilder_           = args_.urlBuilder;
    JFFAsyncOperationBinder dataLoaderForURL_ = args_.dataLoaderForURL;
    JFFAsyncBinderForURL analyzerForData_     = args_.analyzerForData;
    id< JFFRestKitCache > cache_              = args_.cache;
    JFFCacheKeyForURLBuilder cacheKeyForURL_  = args_.cacheKeyForURL;
    NSTimeInterval cacheDataLifeTime_         = args_.cacheDataLifeTime;

    assert( urlBuilder_       );//should not be nil
    assert( dataLoaderForURL_ );//should not be nil

    if ( !analyzerForData_ )
    {
        //JTODO test case when ( !analyzerForData_ )
        analyzerForData_ = ^JFFAsyncOperationBinder( NSURL* url_ )
        {
            JFFAnalyzer analyzer_ = ^id( NSData* data_, NSError** outError_ )
            {
                return data_;
            };
            return asyncOperationBinderWithAnalyzer( analyzer_ );
        };
    }

    NSURL* url_ = urlBuilder_();

    if ( !url_ )
    {
        return asyncOperationWithError( [ JFFRestKitNoURLError new ] );
    }

    id key_ = nil;
    if ( cache_ )
    {
        key_ = cacheKeyForURL_
            ? cacheKeyForURL_( url_ )
            : [ url_ description ];
    }

    JFFAsyncOperation urlLoader_ = asyncOperationWithResult( url_ );

    JFFAsyncOperationBinder cachedDataLoaderForURL_ =
    ^JFFAsyncOperation( NSURL* url_ )
    {
        NSDate* lastUpdateDate_ = nil;
        NSData* cachedData_ = [ cache_ dataForKey: key_
                                   lastUpdateDate: &lastUpdateDate_ ];

        if ( cachedData_ )
        {
            NSDate* newDate_ = [ lastUpdateDate_ dateByAddingTimeInterval: cacheDataLifeTime_ ];
            if ( [ newDate_ compare: [ NSDate new ] ] == NSOrderedDescending )
            {
                JFFResponseDataWithUpdateData* result_ = [ JFFResponseDataWithUpdateData new ];
                result_.updateDate = lastUpdateDate_;
                result_.data       = cachedData_;
                return asyncOperationWithResult( result_ );
            }
        }

        JFFDidFinishAsyncOperationHook finishCallbackHook_ = ^( NSData* srvResponse_
                                                               , NSError* error_
                                                               , JFFDidFinishAsyncOperationHandler doneCallback_ )
        {
            if ( !doneCallback_ )
                return;

            //logs [ srvResponse_ logResponse ];

            if ( srvResponse_ )
            {
                JFFResponseDataWithUpdateData* newResult_ = [ JFFResponseDataWithUpdateData new ];
                newResult_.data = srvResponse_;
                doneCallback_( newResult_, nil );
                return;
            }

            if ( cachedData_ )
            {
                JFFResponseDataWithUpdateData* newResult_ = [ JFFResponseDataWithUpdateData new ];
                newResult_.updateDate = lastUpdateDate_;
                newResult_.data       = cachedData_;
                doneCallback_( newResult_, nil );
                return;
            }

            doneCallback_( nil, error_ );
        };
        return asyncOperationWithFinishHookBlock( dataLoaderForURL_( url_ )
                                                 , finishCallbackHook_ );
    };

    JFFAsyncOperationBinder analizer_ = ^JFFAsyncOperation( JFFResponseDataWithUpdateData* response_ )
    {
        JFFAsyncOperationBinder binder_ = analyzerForData_( url_ );
        JFFAsyncOperation analyzer_ = binder_( response_.data );

        JFFAsyncOperationBinder cacheBinder_ = ^JFFAsyncOperation( id analizedData_ )
        {
            if ( !response_.updateDate )
            {
                [ cache_ setData: response_.data
                          forKey: key_ ];
            }
            return asyncOperationWithResult( analizedData_ );
        };

        return bindSequenceOfAsyncOperations( analyzer_
                                             , cache_ ? cacheBinder_ : nil
                                             , nil );
    };

    return bindSequenceOfAsyncOperations( urlLoader_
                                         , cachedDataLoaderForURL_
                                         , analizer_
                                         , nil );
}

JFFAsyncOperation jSmartDataLoader( NSURL*(^urlBuilder_)(void)
                                   , JFFAsyncOperationBinder dataLoaderForURL_
                                   , JFFAsyncBinderForURL analyzerForData_ )
{
    JFFSmartUrlDataLoaderFields* args_ = [ JFFSmartUrlDataLoaderFields new ];
    args_.urlBuilder       = urlBuilder_;
    args_.dataLoaderForURL = dataLoaderForURL_;
    args_.analyzerForData  = analyzerForData_;

    return jSmartDataLoaderWithCache( args_ );
}
