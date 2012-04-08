#import "JFFSmartUrlDataLoader.h"

#import "JFFRestKitError.h"

@interface JFFResponseDataWithUpdateData : NSObject

@property ( nonatomic, strong ) NSData* data;
@property ( nonatomic, strong ) NSDate* updateDate;

@end

@implementation JFFResponseDataWithUpdateData

@synthesize data       = _data;
@synthesize updateDate = _updateDate;

@end

JFFAsyncOperation jSmartDataLoaderWithCache( NSURL*(^urlBuilder_)(void)
                                            , JFFAsyncOperationBinder dataLoaderForURL_
                                            , JFFAsyncBinderForURL analyzerForData_
                                            , id< JFFRestKitCache > cache_
                                            , id(^keyForURL_)(NSURL*)
                                            , NSTimeInterval lifeTime_ )
{
    NSURL* url_ = urlBuilder_();

    if ( !url_ )
    {
        return asyncOperationWithError( [ JFFRestKitNoURLError new ] );
    }

    id key_ = nil;
    if ( cache_ )
    {
        key_ = keyForURL_
            ? keyForURL_( url_ )
            : [ url_ description ];
    }

    JFFAsyncOperation urlLoader_ = asyncOperationWithResult( url_ );

    dataLoaderForURL_ = [ dataLoaderForURL_ copy ];
    JFFAsyncOperationBinder cachedDataLoaderForURL_ =
    ^JFFAsyncOperation( NSURL* url_ )
    {
        NSDate* lastUpdateDate_ = nil;
        NSData* cachedData_ = [ cache_ dataForKey: key_
                                   lastUpdateDate:  &lastUpdateDate_ ];

        if ( cachedData_ )
        {
            NSDate* newDate_ = [ lastUpdateDate_ dateByAddingTimeInterval: lifeTime_ ];
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
                newResult_.data = cachedData_;
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
    return jSmartDataLoaderWithCache( urlBuilder_
                                     , dataLoaderForURL_
                                     , analyzerForData_
                                     , nil
                                     , nil
                                     , 0. );
}
