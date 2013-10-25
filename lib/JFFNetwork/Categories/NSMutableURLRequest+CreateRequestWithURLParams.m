#import "NSMutableURLRequest+CreateRequestWithURLParams.h"

#import "JFFURLConnectionParams.h"

@implementation NSMutableURLRequest (CreateRequestWithURLParams)

+ (instancetype)mutableURLRequestWithParams:(JFFURLConnectionParams *)params
{
    NSInputStream *inputStream = params.httpBodyStreamBuilder?params.httpBodyStreamBuilder():nil;
    
    NSParameterAssert((!params.httpBody && !inputStream) || !(params.httpBody && inputStream));
    
    static const NSTimeInterval timeout = 60.;
    NSMutableURLRequest *request = [self requestWithURL:params.url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:timeout];
    
    NSString *httpMethod = params.httpMethod ?: @"GET";
    if (!params.httpMethod && (params.httpBody || inputStream)) {
        httpMethod = @"POST";
    }
    
    [request setHTTPBodyStream:inputStream];
    if (params.httpBody)
        [request setHTTPBody:params.httpBody];
    
    [request setAllHTTPHeaderFields:params.headers];
    [request setHTTPMethod         :httpMethod    ];
    
    return request;
}

@end
