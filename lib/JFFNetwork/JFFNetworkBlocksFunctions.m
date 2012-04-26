#import "JFFNetworkBlocksFunctions.h"

#import "JFFURLConnectionParams.h"
#import "JFFAsyncOperationNetwork.h"

#import "NSURL+Cookies.h"

JFFAsyncOperation genericChunkedURLResponseLoader( JFFURLConnectionParams* params_ )
{
    JFFAsyncOperationNetwork* asyncObj_ = [ JFFAsyncOperationNetwork new ];
    asyncObj_.params = params_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

JFFAsyncOperation genericDataURLResponseLoader( JFFURLConnectionParams* params_ )
{
    return ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                     , JFFCancelAsyncOperationHandler cancelCallback_
                                     , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        JFFAsyncOperation loader_ = genericChunkedURLResponseLoader( params_ );

        NSMutableData* responseData_ = [ NSMutableData new ];
        progressCallback_ = [ progressCallback_ copy ];
        JFFAsyncOperationProgressHandler dataProgressCallback_ = ^void( id progressInfo_ )
        {
            if ( progressCallback_ )
                progressCallback_( progressInfo_ );
            [ responseData_ appendData: progressInfo_ ];
        };

        JFFDidFinishAsyncOperationHandler doneCallbackWrapper_ = nil;
        if ( doneCallback_ )
        {
            doneCallback_ = [ doneCallback_ copy ];
            doneCallbackWrapper_ = ^void( id result_, NSError* error_ )
            {
                doneCallback_( result_ ? responseData_ : nil, error_ );
            };
        }

        return loader_( dataProgressCallback_, cancelCallback_, doneCallbackWrapper_ );
    };
}

#pragma mark -
#pragma mark Compatibility

JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    return genericChunkedURLResponseLoader( params_ );
}

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    return genericDataURLResponseLoader( params_ );
}

JFFAsyncOperation liveChunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    params_.useLiveConnection = YES;
    return genericChunkedURLResponseLoader( params_ );
}

JFFAsyncOperation liveDataURLResponseLoader(
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ JFFURLConnectionParams new ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    params_.useLiveConnection = YES;
    return genericDataURLResponseLoader( params_ );
}
