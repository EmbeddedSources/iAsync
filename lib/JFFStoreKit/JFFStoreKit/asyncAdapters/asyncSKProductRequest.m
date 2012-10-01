#import "asyncSKProductRequest.h"

@interface JFFAsyncSKProductsRequestAdapter : NSObject <
JFFAsyncOperationInterface,
SKProductsRequestDelegate
>

@end

@implementation JFFAsyncSKProductsRequestAdapter
{
    SKProductsRequest *_request;
    JFFAsyncOperationInterfaceHandler _handler;
    SKProductsResponse *_response;
}

- (id)initWithProductIdentifier:(NSString *)productIdentifier
{
    self = [super init];
    
    if (self)
    {
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                     [NSSet setWithObject:productIdentifier]];
        
        self->_request   = request;
        request.delegate = self;
    }
    
    return self;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    self->_handler = [handler copy];
    
    [self->_request start];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled)
        [self->_request cancel];
}

#pragma mark SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    NSArray *products = self->_response.products;
    if ([products hasElements]) {
        self->_handler(products, nil);
    } else {
        //TODO create separate error
        self->_handler(nil, [JFFError newErrorWithDescription:@"can not ta ta ta"]);
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self->_handler(nil, error);
}

#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self->_response = response;
}

@end

JFFAsyncOperation asyncOperationWithProductIdentifier(NSString *identifier)
{
    id asyncObject = [[JFFAsyncSKProductsRequestAdapter alloc] initWithProductIdentifier:identifier];
    return buildAsyncOperationWithInterface(asyncObject);
}
