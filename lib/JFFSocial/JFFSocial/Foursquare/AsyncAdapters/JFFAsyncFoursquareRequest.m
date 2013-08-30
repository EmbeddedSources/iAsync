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
                                                        NSMutableData *httpBody,
                                                        NSString *accessToken,
                                                        NSDictionary *parameters)
{
    NSCParameterAssert(accessToken);
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    
    NSDictionary *requaredParams = requaredParamsWithAccessToken(accessToken);
    NSDictionary *fullParams = [requaredParams dictionaryByAddingObjectsFromDictionary:parameters];
    
    NSString *paramsString = [fullParams stringFromQueryComponents];
    
    params.httpMethod = httpMethod;
    
    if ([httpMethod isEqualToString:@"POST"]) {
        params.url = [requestURL toURL];
        if (httpBody) {
            NSString *boundary = [NSString createUuid];
            [httpBody appendHTTPParameters:fullParams boundary:boundary];
            params.headers = @{ @"Content-Type" : @"multipart/form-data" };
        } else {
            params.httpBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            params.headers = @{ @"Content-Type" : @"application/x-www-form-urlencoded" };
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

JFFAsyncOperation jffFoursquareRequestLoaderWithHTTPBody (NSString *requestURL, NSMutableData *httpBody, NSString *accessToken)
{
    return generalFoursquareRequestLoader(requestURL,
                                          @"POST",
                                          httpBody,
                                          accessToken,
                                          nil);
}
