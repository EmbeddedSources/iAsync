#import "JFFAsyncTwitterRequest.h"

#import <Social/Social.h>

@implementation JFFTwitterResponse
@end

@interface JFFAsyncTwitterRequest : NSObject <JFFAsyncOperationInterface>
@end

@implementation JFFAsyncTwitterRequest
{
@public
    SLRequest *_request;
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

- (BOOL)isForeignThreadResultCallback
{
    return YES;
}

@end

JFFAsyncOperation jffTwitterRequest(SLRequest *request)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        JFFAsyncTwitterRequest *object = [JFFAsyncTwitterRequest new];
        object->_request = request;
        return object;
    };
    
    return buildAsyncOperationWithAdapterFactory(factory);
}
