#import "JFFNetworkBlocksFunctions.h"

#import "JNUrlResponse.h"
#import "JHttpFlagChecker.h"
#import "JFFURLConnectionParams.h"
#import "JFFNetworkAsyncOperation.h"

#import "JFFNetworkResponseDataCallback.h"

//Errors
#import "JHttpError.h"
#import "JNSNetworkError.h"

#import "NSURL+Cookies.h"

#import <JFFAsyncOperations/AsyncOperartionsBuilder/JFFAsyncOperationBuilder.h>

static JFFAnalyzer downloadStatusCodeResponseAnalyzer(id<NSCopying> context)
{
    return ^id(id<JNUrlResponse> response, NSError **outError) {
        
        NSInteger statusCode = [response statusCode];
        
        if ([JHttpFlagChecker isDownloadErrorFlag:statusCode]) {
            if (outError) {
                JHttpError *httpError = [[JHttpError alloc] initWithHttpCode:statusCode];
                httpError.context = context;
                *outError = httpError;
            }
            return nil;
        }
        
        return response;
    };
}

static JFFNetworkErrorTransformer networkErrorAnalyzer(id<NSCopying> context)
{
    return ^NSError *(NSError *error) {

        if ([error isKindOfClass:[JNetworkError class]])
            return error;
        
        JNSNetworkError *resultError = [JNSNetworkError newJNSNetworkErrorWithContext:context
                                                                          nativeError:error];
        
        return resultError;
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
        asyncObj.errorTransformer = networkErrorAnalyzer(params);
        return asyncObj;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}

JFFAsyncOperation genericChunkedURLResponseLoader(JFFURLConnectionParams* params)
{
    return privateGenericChunkedURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params));
}

static JFFAsyncOperation privateGenericDataURLResponseLoader(JFFURLConnectionParams *params,
                                                             JFFAnalyzer responseAnalyzer)
{
    NSCParameterAssert([params.url isKindOfClass:[NSURL class]]);
    params = [params copy];
    return ^JFFAsyncOperationHandler(JFFAsyncOperationProgressCallback progressCallback,
                                     JFFAsyncOperationChangeStateCallback stateCallback,
                                     JFFDidFinishAsyncOperationCallback doneCallback) {
        
        JFFAsyncOperation loader = privateGenericChunkedURLResponseLoader(params, responseAnalyzer);
        
        NSMutableData *responseData = [NSMutableData new];
        progressCallback = [progressCallback copy];
        JFFAsyncOperationProgressCallback dataProgressCallback = ^void(id progressInfo) {
            
            if ([progressInfo isKindOfClass:[JFFNetworkResponseDataCallback class]]) {
                
                JFFNetworkResponseDataCallback *responseChunkData = progressInfo;
                [responseData appendData:responseChunkData.dataChunk];
            }
            if (progressCallback)
                progressCallback(progressInfo);
        };
        
        /*NSArray *skipPt = @[@"profile/profileapi/changes", @"/info/api/report", @"/api/addDeviceProfileId"];
        
        if ([skipPt all:^BOOL(id object) {
            return ![[params.url description] containsString:object];
        }])*/
        //NSLog(@"start url: %@", params.url);
        
        JFFDidFinishAsyncOperationCallback doneCallbackWrapper;
        if (doneCallback) {
            doneCallback = [doneCallback copy];
            doneCallbackWrapper = ^void(id result, NSError *error) {
                
                if ([responseData length] == 0 && !error) {
                    NSLog(@"!!!WARNING!!! request with params: %@ got an empty response", params);
                }
                /*if ([skipPt all:^BOOL(id object) {
                    return ![[params.url description] containsString:object];
                }])
                //NSLog(@"done url: %@ response: %@  \n \n", params.url, [responseData toString]);*/
                //NSLog(@"done url: %@", params.url);
                doneCallback(result?responseData:nil, error);
            };
        }
        
        return loader(dataProgressCallback, stateCallback, doneCallbackWrapper);
    };
}

JFFAsyncOperation genericDataURLResponseLoader(JFFURLConnectionParams *params)
{
    return privateGenericDataURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params) );
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
    return privateGenericChunkedURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params));
}

JFFAsyncOperation dataURLResponseLoader(NSURL *url,
                                        NSData *postData,
                                        NSDictionary *headers)
{
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url      = url;
    params.httpBody = postData;
    params.headers  = headers;
    return privateGenericDataURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params));
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
    return privateGenericChunkedURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params));
}

JFFAsyncOperation liveDataURLResponseLoader(NSURL* url,
                                            NSData* postData,
                                            NSDictionary* headers)
{
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    params.url      = url;
    params.httpBody = postData;
    params.headers  = headers;
    params.useLiveConnection = YES;
    return privateGenericDataURLResponseLoader(params, downloadStatusCodeResponseAnalyzer(params));
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
