#import "JFFAsyncFoursquareRequest.h"

@interface JFFAsyncFoursquareRequest : NSObject <JFFAsyncOperationInterface>

@property (nonatomic) NSString *requestURL;
@property (nonatomic) NSString *httpMethod;

@property (copy, nonatomic) JFFCancelAsyncOperation cancelRequestOperation;

@end


@implementation JFFAsyncFoursquareRequest

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    handler = [handler copy];
    
//    JFFURLConnectionParams *params = [JFFURLConnectionParams new];
    
//    params.url = self.requestURL
}

- (void)cancel:(BOOL)canceled
{
    
}

@end


JFFAsyncOperation jffFoursquareRequestLoader (NSString *requestURL, NSString *httpMethod)
{
    JFFAsyncFoursquareRequest *request = [JFFAsyncFoursquareRequest new];
    request.requestURL = requestURL;
    request.httpMethod = httpMethod;
    
    return buildAsyncOperationWithInterface(request);
}