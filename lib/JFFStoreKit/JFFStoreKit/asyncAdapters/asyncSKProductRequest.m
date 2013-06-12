#import "asyncSKProductRequest.h"

#import "JFFStoreKitCanNoLoadProductError.h"
#import "JFFStoreKitInvalidProductIdentifierError.h"

@interface JFFAsyncSKProductsRequestAdapter : NSObject <
JFFAsyncOperationInterface,
SKProductsRequestDelegate
>

@end

@implementation JFFAsyncSKProductsRequestAdapter
{
    SKProductsRequest                *_request;
    JFFAsyncOperationInterfaceResultHandler _handler;
    SKProductsResponse               *_response;
    NSString                         *_productIdentifier;
}

- (instancetype)initWithProductIdentifier:(NSString *)productIdentifier
{
    self = [super init];
    
    if (self) {
        _productIdentifier = productIdentifier;
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:
                                     [NSSet setWithObject:productIdentifier]];
        
        _request   = request;
        request.delegate = self;
    }
    
    return self;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    _handler = [handler copy];
    
    [_request start];
}

- (void)cancel:(BOOL)canceled
{
    if (canceled)
        [_request cancel];
}

#pragma mark SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    NSArray *products = _response.products;
    if ([products hasElements]) {
        _handler([products lastObject], nil);
    } else {
        
        NSString *invalidIdentifier = [_response.invalidProductIdentifiers lastObject];
        
        JFFStoreKitCanNoLoadProductError *error = ([invalidIdentifier isEqualToString:_productIdentifier])
        ? [JFFStoreKitInvalidProductIdentifierError new]
        : [JFFStoreKitCanNoLoadProductError new];
        
        error.productIdentifier = _productIdentifier;
        _handler(nil, error);
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    _handler(nil, error);
}

#pragma mark SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _response = response;
}

@end

JFFAsyncOperation skProductLoaderWithProductIdentifier(NSString *identifier)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [[JFFAsyncSKProductsRequestAdapter alloc] initWithProductIdentifier:identifier];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
