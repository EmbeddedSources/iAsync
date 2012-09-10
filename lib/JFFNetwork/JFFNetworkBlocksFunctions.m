#import "JFFNetworkBlocksFunctions.h"

#import "JHttpError.h"
#import "JNUrlResponse.h"
#import "JHttpFlagChecker.h"
#import "JFFURLConnectionParams.h"
#import "JFFAsyncOperationNetwork.h"

#import "NSURL+Cookies.h"

JFFAsyncOperation genericChunkedURLResponseLoader(JFFURLConnectionParams *params)
{
    JFFAsyncOperationNetwork* asyncObj = [JFFAsyncOperationNetwork new];
    asyncObj.params = params;
    asyncObj.responseAnalyzer = ^id(id< JNUrlResponse > response, NSError **error)
    {
        NSInteger statusCode = [response statusCode];

        if ([JHttpFlagChecker isDownloadErrorFlag:statusCode])
        {
            if (error)
            {
                JHttpError *httpError = [[JHttpError alloc]initWithHttpCode:statusCode];
                [httpError setToPointer:error];
            }
            return nil;
        }

        return response;
    };

    return buildAsyncOperationWithInterface(asyncObj);
}

JFFAsyncOperation genericDataURLResponseLoader(JFFURLConnectionParams *params)
{
    params = [params copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback)
    {
        JFFAsyncOperation loader = genericChunkedURLResponseLoader(params);

        NSMutableData* responseData = [ NSMutableData new ];
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressHandler dataProgressCallback = ^void(id progressInfo)
        {
            if (progressCallback)
                progressCallback(progressInfo);
            [responseData appendData:progressInfo];
        };

        JFFDidFinishAsyncOperationHandler doneCallbackWrapper;
        if (doneCallback)
        {
            doneCallback = [doneCallback copy];
            doneCallbackWrapper = ^void(id result, NSError *error)
            {
                doneCallback(result?responseData:nil, error);
            };
        }

        return loader(dataProgressCallback, cancelCallback, doneCallbackWrapper);
    };
}

#pragma mark -
#pragma mark Compatibility

JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [JFFURLConnectionParams new];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    return genericChunkedURLResponseLoader(params_);
}

JFFAsyncOperation dataURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params = [JFFURLConnectionParams new];
    params.url      = url_;
    params.httpBody = postData_;
    params.headers  = headers_;
    return genericDataURLResponseLoader(params);
}

JFFAsyncOperation liveChunkedURLResponseLoader( 
   NSURL* url_
   , NSData* postData_
   , NSDictionary* headers_ )
{
    JFFURLConnectionParams* params_ = [JFFURLConnectionParams new];
    params_.url      = url_;
    params_.httpBody = postData_;
    params_.headers  = headers_;
    params_.useLiveConnection = YES;
    return genericChunkedURLResponseLoader(params_);
}

JFFAsyncOperation liveDataURLResponseLoader(
   NSURL* url
   , NSData* postData
   , NSDictionary* headers )
{
    JFFURLConnectionParams* params_ = [JFFURLConnectionParams new];
    params_.url      = url;
    params_.httpBody = postData;
    params_.headers  = headers;
    params_.useLiveConnection = YES;
    return genericDataURLResponseLoader(params_);
}
