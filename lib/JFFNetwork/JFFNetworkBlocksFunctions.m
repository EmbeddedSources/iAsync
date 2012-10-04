#import "JFFNetworkBlocksFunctions.h"

#import "JHttpError.h"
#import "JNUrlResponse.h"
#import "JHttpFlagChecker.h"
#import "JFFURLConnectionParams.h"
#import "JFFAsyncOperationNetwork.h"

#import "NSURL+Cookies.h"

static JFFAnalyzer downloadErrorFlagResponseAnalyzer()
{
    return ^id(id< JNUrlResponse > response, NSError **error) {
        NSInteger statusCode = [response statusCode];
        
        if ([JHttpFlagChecker isDownloadErrorFlag:statusCode]) {
            if (error) {
                JHttpError *httpError = [[JHttpError alloc]initWithHttpCode:statusCode];
                [httpError setToPointer:error];
            }
            return nil;
        }
        
        return response;
    };
}

static JFFAsyncOperation privateGenericChunkedURLResponseLoader(JFFURLConnectionParams *params,
                                                                JFFAnalyzer responseAnalyzer)
{
    JFFAsyncOperationNetwork* asyncObj = [JFFAsyncOperationNetwork new];
    asyncObj.params           = params;
    asyncObj.responseAnalyzer = responseAnalyzer;
    
    return buildAsyncOperationWithInterface(asyncObj);
}

JFFAsyncOperation genericChunkedURLResponseLoader(JFFURLConnectionParams* params)
{
    return privateGenericChunkedURLResponseLoader(params, nil);
}

static JFFAsyncOperation privateGenericDataURLResponseLoader(JFFURLConnectionParams *params,
                                                             JFFAnalyzer responseAnalyzer)
{
    params = [params copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        JFFAsyncOperation loader = privateGenericChunkedURLResponseLoader(params, responseAnalyzer);
        
        NSMutableData* responseData = [NSMutableData new];
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressHandler dataProgressCallback = ^void(id progressInfo) {
            if (progressCallback)
                progressCallback(progressInfo);
            //TODO think about it
            if ([progressInfo isKindOfClass:[NSData class]])
                [responseData appendData:progressInfo];
        };
        
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper;
        if (doneCallback) {
            doneCallback = [doneCallback copy];
            doneCallbackWrapper = ^void(id result, NSError *error) {
                doneCallback(result?responseData:nil, error);
            };
        }
        
        return loader(dataProgressCallback, cancelCallback, doneCallbackWrapper);
    };
}

JFFAsyncOperation genericDataURLResponseLoader(JFFURLConnectionParams *params)
{
    return privateGenericDataURLResponseLoader(params, nil);
}

#pragma mark -
#pragma mark Compatibility

JFFAsyncOperation chunkedURLResponseLoader( 
   NSURL  *url,
   NSData *postData,
   NSDictionary *headers)
{
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url      = url;
    params.httpBody = postData;
    params.headers  = headers;
    return privateGenericChunkedURLResponseLoader(params, downloadErrorFlagResponseAnalyzer());
}

JFFAsyncOperation dataURLResponseLoader(NSURL *url,
                                        NSData* postData,
                                        NSDictionary *headers)
{
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url      = url;
    params.httpBody = postData;
    params.headers  = headers;
    return privateGenericDataURLResponseLoader(params, downloadErrorFlagResponseAnalyzer());
}

JFFAsyncOperation liveChunkedURLResponseLoader(NSURL *url,
                                               NSData *postData,
                                               NSDictionary *headers)
{
    JFFURLConnectionParams* params = [JFFURLConnectionParams new];
    params.url      = url;
    params.httpBody = postData;
    params.headers  = headers;
    params.useLiveConnection = YES;
    return privateGenericChunkedURLResponseLoader(params, downloadErrorFlagResponseAnalyzer());
}

JFFAsyncOperation liveDataURLResponseLoader(NSURL* url,
                                            NSData* postData,
                                            NSDictionary* headers)
{
    JFFURLConnectionParams* params_ = [JFFURLConnectionParams new];
    params_.url      = url;
    params_.httpBody = postData;
    params_.headers  = headers;
    params_.useLiveConnection = YES;
    return privateGenericDataURLResponseLoader(params_, downloadErrorFlagResponseAnalyzer());
}

JFFAsyncOperation perkyDataURLResponseLoader(NSURL *url,
                                             NSData *postData,
                                             NSDictionary *headers)
{
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url      = url;
    params.httpBody = postData;
    params.headers  = headers;
    return genericDataURLResponseLoader(params);
}
