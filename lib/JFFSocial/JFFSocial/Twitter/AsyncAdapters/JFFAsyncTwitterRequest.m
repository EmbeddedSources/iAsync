#import "JFFAsyncTwitterRequest.h"

#import <Twitter/Twitter.h>

@implementation JFFTwitterResponse
@end

@interface JFFAsyncTwitterRequest : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterRequest
{
@public
    TWRequest *_request;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    [_request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (!handler)
            return;
        
        if (error) {
            
            handler(nil, error);
        } else {
            
            JFFTwitterResponse *result = [JFFTwitterResponse new];
            result.responseData = responseData;
            result.urlResponse  = urlResponse;
            
            handler(result, nil);
        }
    }];
}

- (void)cancel:(BOOL)canceled
{
}

@end

JFFAsyncOperation jffTwitterRequest(TWRequest *request)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFAsyncTwitterRequest *object = [JFFAsyncTwitterRequest new];
        object->_request = request;
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
