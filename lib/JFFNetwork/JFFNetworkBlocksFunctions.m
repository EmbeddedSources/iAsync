#import "JFFNetworkBlocksFunctions.h"

#import "JHttpError.h"
#import "JNUrlResponse.h"
#import "JHttpFlagChecker.h"
#import "JFFURLConnectionParams.h"
#import "JFFNetworkAsyncOperation.h"

#import "JFFNetworkResponseDataCallback.h"

#import "NSURL+Cookies.h"

static JFFAnalyzer downloadErrorFlagResponseAnalyzer()
{
    return ^id(id< JNUrlResponse > response, NSError **outError) {
        NSInteger statusCode = [response statusCode];
        
        if ([JHttpFlagChecker isDownloadErrorFlag:statusCode]) {
            if (outError) {
                JHttpError *httpError = [[JHttpError alloc]initWithHttpCode:statusCode];
                *outError = httpError;
            }
            return nil;
        }
        
        return response;
    };
}

static JFFAsyncOperation privateGenericChunkedURLResponseLoader(JFFURLConnectionParams *params,
                                                                JFFAnalyzer responseAnalyzer)
{
    responseAnalyzer = [responseAnalyzer copy];
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>() {
        //NSLog(@"url: %@", params.url);
        JFFNetworkAsyncOperation *asyncObj = [JFFNetworkAsyncOperation new];
        asyncObj.params           = params;
        asyncObj.responseAnalyzer = responseAnalyzer;
        return asyncObj;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

JFFAsyncOperation genericChunkedURLResponseLoader(JFFURLConnectionParams* params)
{
    return privateGenericChunkedURLResponseLoader(params, nil);
}

static JFFAsyncOperation privateGenericDataURLResponseLoader(JFFURLConnectionParams *params,
                                                             JFFAnalyzer responseAnalyzer)
{
    assert([params.url isKindOfClass:[NSURL class]]);
    params = [params copy];
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        JFFAsyncOperation loader = privateGenericChunkedURLResponseLoader(params, responseAnalyzer);
        
        NSMutableData *responseData = [NSMutableData new];
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressHandler dataProgressCallback = ^void(id progressInfo) {
            
            if ([progressInfo isKindOfClass:[JFFNetworkResponseDataCallback class]]) {
                
                JFFNetworkResponseDataCallback *responseChunkData = progressInfo;
                [responseData appendData:responseChunkData.dataChunk];
            }
            if (progressCallback)
                progressCallback(progressInfo);
        };
        
        JFFDidFinishAsyncOperationHandler doneCallbackWrapper;
        if (doneCallback) {
            doneCallback = [doneCallback copy];
            doneCallbackWrapper = ^void(id result, NSError *error) {
                
                if ([responseData length] == 0 && !error) {
                    NSLog(@"!!!WARNING!!! request with params: %@ got an empty reponse", params);
                }
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
                                        NSData *postData,
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
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
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
    JFFURLConnectionParams *params_ = [JFFURLConnectionParams new];
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
