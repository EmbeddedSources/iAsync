#import "JFFAsyncFoursquareRequest.h"

#define FOURSQUARE_VERSION @"20120913"

@interface JFFAsyncFoursquareRequest : NSObject <JFFAsyncOperationInterface>

@property (nonatomic) NSString *requestURL;
@property (nonatomic) NSString *httpMethod;
@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSDictionary *parameters;

@property (nonatomic) NSData *httpBody;

@property (copy, nonatomic) JFFCancelAsyncOperation cancelRequestOperation;

@end


@implementation JFFAsyncFoursquareRequest

- (NSDictionary *)requaredRequestParameters
{
    return @{ @"v" : FOURSQUARE_VERSION,
    @"oauth_token" : self.accessToken };
}

- (NSDictionary *)fullRequestParameters
{
    return [[self requaredRequestParameters] dictionaryByAddingObjectsFromDictionary:self.parameters];
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    
    NSString *paramsString = [[self fullRequestParameters] stringFromQueryComponents];
    
    params.httpMethod = self.httpMethod;
    
    if ([self.httpMethod isEqualToString:@"POST"])
    {
        params.url = [self.requestURL toURL];
        if (self.httpBody)
        {
            NSDictionary *requaredParams = [self requaredRequestParameters];
            params.httpBody = [self.httpBody dataForHTTPPostByAppendingParameters:requaredParams];
        }
        else
        {
            self.httpBody = [paramsString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        }
    }
    else
    {
        params.url = [ [NSString stringWithFormat:@"%@?%@", self.requestURL, paramsString] toURL];
    }

    JFFAsyncOperation dataLoader = genericDataURLResponseLoader(params);
    
    self.cancelRequestOperation = dataLoader (nil, nil, ^(id result, NSError *error)
                                              {
                                                  handler (result, error);
                                              });
}

- (void)cancel:(BOOL)canceled
{
    if (self.cancelRequestOperation) {
        self.cancelRequestOperation (canceled);
    }
}

@end


JFFAsyncOperation jffFoursquareRequestLoader (NSString *requestURL, NSString *httpMethod, NSString *accessToken, NSDictionary *parameters)
{
    JFFAsyncFoursquareRequest *request = [JFFAsyncFoursquareRequest new];
    request.requestURL = requestURL;
    request.httpMethod = httpMethod;
    request.accessToken = accessToken;
    request.parameters = parameters;
    
    return buildAsyncOperationWithInterface(request);
}

JFFAsyncOperation jffFoursquareRequestLoaderWithHTTPBody (NSString *requestURL, NSData *httpBody, NSString *accessToken)
{
    JFFAsyncFoursquareRequest *request = [JFFAsyncFoursquareRequest new];
    request.requestURL = requestURL;
    request.httpBody = httpBody;
    request.accessToken = accessToken;
    request.httpMethod = @"POST";
    
    return buildAsyncOperationWithInterface(request);
}