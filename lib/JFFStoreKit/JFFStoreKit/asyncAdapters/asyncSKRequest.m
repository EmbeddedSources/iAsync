#import "asyncSKRequest.h"

@interface JFFAsyncSKRequestAdapter : NSObject <
JFFAsyncOperationInterface,
SKRequestDelegate
>

@end

@implementation JFFAsyncSKRequestAdapter
{
    SKRequest *_request;
    JFFAsyncOperationInterfaceHandler _handler;
}

+ (id)newAsyncSKRequestAdapterWithRequest:(SKRequest *)request
{
    JFFAsyncSKRequestAdapter *result = [self new];
    
    if (result) {
        result->_request = request;
        request.delegate = result;
    }
    
    return result;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    self->_handler = [handler copy];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled)
        [self->_request cancel];
}

#pragma mark SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    self->_handler(request, nil);
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self->_handler(nil, error);
}

@end

JFFAsyncOperation asyncOperationWithSKRequest(SKRequest *request)
{
    id asyncObject = [JFFAsyncSKRequestAdapter newAsyncSKRequestAdapterWithRequest:request];
    return buildAsyncOperationWithInterface(asyncObject);
}
