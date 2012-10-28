#import "JFFAsyncFoursquareRequest.h"

#define FOURSQUARE_VERSION @"20120913"

static NSDictionary *requaredParamsWithAccessToken(NSString *accessToken)
{
    return @{
    @"v" : FOURSQUARE_VERSION,
    @"oauth_token" : accessToken
    };
}

static JFFAsyncOperation generalFoursquareRequestLoader(NSString *requestURL,
                                                        NSString *httpMethod,
                                                        NSData *httpBody,
                                                        NSString *accessToken,
                                                        NSDictionary *parameters)
{
    assert(accessToken);
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    
    NSDictionary *requaredParams = requaredParamsWithAccessToken(accessToken);
    
    NSString *paramsString = [[requaredParams dictionaryByAddingObjectsFromDictionary:parameters] stringFromQueryComponents];
    
    params.httpMethod = httpMethod;
    
    if ([httpMethod isEqualToString:@"POST"]) {
        params.url = [requestURL toURL];
        if (httpBody) {
            //may should pass (requaredParams + parameters) instead off requaredParams here
            params.httpBody = [httpBody dataForHTTPPostByAppendingParameters:requaredParams];
        } else {
            httpBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        }
    } else {
        params.url = [ [NSString stringWithFormat:@"%@?%@", requestURL, paramsString] toURL];
    }
    
    return genericDataURLResponseLoader(params);
}

JFFAsyncOperation jffFoursquareRequestLoader (NSString *requestURL, NSString *httpMethod, NSString *accessToken, NSDictionary *parameters)
{
    return generalFoursquareRequestLoader(requestURL,
                                          httpMethod,
                                          nil,
                                          accessToken,
                                          parameters);
}

JFFAsyncOperation jffFoursquareRequestLoaderWithHTTPBody (NSString *requestURL, NSData *httpBody, NSString *accessToken)
{
    return generalFoursquareRequestLoader(requestURL,
                                          @"POST",
                                          httpBody,
                                          accessToken,
                                          nil);
}
