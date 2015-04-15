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
    JFFDidFinishAsyncOperationCallback _finishCallback;
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

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    _finishCallback = [finishCallback copy];
    
    [_request start];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSCParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskCancel) {
        [_request cancel];
    }
}

#pragma mark SKRequestDelegate

- (void)requestDidFinish:(SKRequest *)request
{
    NSArray *products = _response.products;
    if ([products count] > 0) {
        
        SKProduct *product = [products firstMatch:^BOOL(SKProduct *product) {
            return [product.productIdentifier isEqualToString:_productIdentifier];
        }];
        
        if (!product) {
            
            NSString *log = [[NSString alloc] initWithFormat:@"requestDidFinish products does not contains product with id: %@", _productIdentifier];
            [[JLogger sharedJLogger] logError:log];
            product = [products lastObject];
        }
        
        _finishCallback(product, nil);
    } else {
        
        NSString *invalidIdentifier = [_response.invalidProductIdentifiers lastObject];
        
        JFFStoreKitCanNoLoadProductError *error = ([invalidIdentifier isEqualToString:_productIdentifier])
        ?[JFFStoreKitInvalidProductIdentifierError new]
        :[JFFStoreKitCanNoLoadProductError new];
        
        error.productIdentifier = _productIdentifier;
        _finishCallback(nil, error);
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    error = error?:[[JFFSilentError alloc] initWithDescription:@"SKRequest no inet connection"];
    _finishCallback(nil, error);
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
