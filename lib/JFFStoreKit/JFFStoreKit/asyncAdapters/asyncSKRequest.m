#import "asyncSKRequest.h"

@interface JFFAsyncSKRequestAdapter : NSObject <
JFFAsyncOperationInterface,
SKRequestDelegate
>

@end

@implementation JFFAsyncSKRequestAdapter
{
    SKRequest *_request;
    JFFAsyncOperationInterfaceResultHandler _handler;
}

+ (instancetype)newAsyncSKRequestAdapterWithRequest:(SKRequest *)request
{
    JFFAsyncSKRequestAdapter *result = [self new];
    
    if (result) {
        result->_request = request;
        request.delegate = result;
    }
    
    return result;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    _handler = [handler copy];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled)
        [_request cancel];
}

#pragma mark SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    _handler(request, nil);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    _handler(nil, error);
}

@end

JFFAsyncOperation asyncOperationWithSKRequest(SKRequest *request)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncSKRequestAdapter newAsyncSKRequestAdapterWithRequest:request];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
