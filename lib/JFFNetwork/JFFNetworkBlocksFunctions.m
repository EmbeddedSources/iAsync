#import "JFFNetworkBlocksFunctions.h"

#import "JFFLocalCookiesStorage.h"
#import "JNConnectionsFactory.h"
#import "JFFURLConnection.h"
#import "JFFURLConnectionParams.h"
#import "JFFAsyncOperationNetwork.h"//JTODO remove redundant headers

#import "NSURL+Cookies.h"

JFFAsyncOperation genericChunkedURLResponseLoader( JFFURLConnectionParams* params_ )
{
    JFFAsyncOperationNetwork* asyncObj_ = [ [ JFFAsyncOperationNetwork new ] autorelease ];
    asyncObj_.params = params_;
    return buildAsyncOperationWithInterface( asyncObj_ );
}

JFFAsyncOperation genericDataURLResponseLoader( JFFURLConnectionParams* params_ )
{
    return [ [ ^JFFCancelAsyncOperation( JFFAsyncOperationProgressHandler progressCallback_
                                        , JFFCancelAsyncOperationHandler cancelCallback_
                                        , JFFDidFinishAsyncOperationHandler doneCallback_ )
    {
        JFFAsyncOperation loader_ = genericChunkedURLResponseLoader( params_ );

        NSMutableData* responseData_ = [ NSMutableData data ];
        progressCallback_ = [ [ progressCallback_ copy ] autorelease ];
        JFFAsyncOperationProgressHandler dataProgressCallback_ = ^void( id progressInfo_ )
        {
            if ( progressCallback_ )
                progressCallback_( progressInfo_ );
            [ responseData_ appendData: progressInfo_ ];
        };

        if ( doneCallback_ )
        {
            doneCallback_ = [ [ doneCallback_ copy ] autorelease ];
            doneCallback_ = ^void( id result_, NSError* error_ )
            {
                doneCallback_( result_ ? responseData_ : nil, error_ );
            };
        }

        return loader_( dataProgressCallback_, cancelCallback_, doneCallback_ );
    } copy ] autorelease ];
}

#pragma mark -
#pragma mark Compatibility

JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
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
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
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
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
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
    JFFURLConnectionParams* params_ = [ [ JFFURLConnectionParams new ] autorelease ];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    params_.useLiveConnection = YES;
    return genericDataURLResponseLoader( params_ );
}
