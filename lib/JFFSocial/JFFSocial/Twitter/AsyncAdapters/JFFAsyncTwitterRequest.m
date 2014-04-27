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

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    [_request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (!finishCallback)
            return;
        
        if (error) {
            
            finishCallback(nil, error);
        } else {
            
            JFFTwitterResponse *result = [JFFTwitterResponse new];
            result.responseData = responseData;
            result.urlResponse  = urlResponse;
            
            finishCallback(result, nil);
        }
    }];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
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
