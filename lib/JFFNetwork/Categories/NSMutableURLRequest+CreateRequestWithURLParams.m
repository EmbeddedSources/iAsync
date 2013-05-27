#import "NSMutableURLRequest+CreateRequestWithURLParams.h"

#import "JNNsUrlConnection.h"
#import "JFFURLConnectionParams.h"

@implementation NSMutableURLRequest (CreateRequestWithURLParams)

+ (id)mutableURLRequestWithParams:(JFFURLConnectionParams *)params
{
    NSParameterAssert((!params.httpBody && !params.httpBodyStream) || !(params.httpBody && params.httpBodyStream));
    
    static const NSTimeInterval timeout = 60.;
    NSMutableURLRequest *request = [self requestWithURL:params.url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:timeout];
    
    NSString *httpMethod = params.httpMethod ?: @"GET";
    if (!params.httpMethod && (params.httpBody || params.httpBodyStream)) {
        httpMethod = @"POST";
    }
    
    [request setHTTPBodyStream:params.httpBodyStream];
    if (params.httpBody)
        [request setHTTPBody:params.httpBody];
    
    [request setAllHTTPHeaderFields:params.headers];
    [request setHTTPMethod         :httpMethod    ];
    
    return request;
}

@end
