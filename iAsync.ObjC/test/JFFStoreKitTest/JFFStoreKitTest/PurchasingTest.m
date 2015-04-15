
#import <JFFTestTools/GHAsyncTestCase+MainThreadTests.h>

static NSString *const testProductIdentifier = @"test.free.purchase1";

@interface PurchasingTest : GHAsyncTestCase
@end

@implementation PurchasingTest

- (void)testFreePurchaseWithProductIdentifier
{
    __block id purchaseResult;
    __block NSString *productIdentifier;
    
    void(^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishBLock) {
        
        JFFAsyncOperationBinder srvCallback = ^JFFAsyncOperation(SKPaymentTransaction *transaction) {
            productIdentifier = transaction.payment.productIdentifier; //product.productIdentifier;
            return asyncOperationWithResult(@YES);
        };
        JFFAsyncOperation loader = [JFFPurchsing purcheserWithProductIdentifier:testProductIdentifier
                                                                    srvCallback:srvCallback];
        
        loader(nil, nil, ^(id result, NSError *error) {
            purchaseResult = result;
            
            finishBLock();
        });
    };
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd];
    
    GHAssertNotNil(purchaseResult, nil);
    GHAssertEqualObjects(productIdentifier, testProductIdentifier, nil);
}

- (void)testFreePurchaseWithProduct
{
    __block id purchaseResult;
    __block NSString *productIdentifier;
    
    void(^testBlock)(JFFSimpleBlock) = ^(JFFSimpleBlock finishBLock) {
        
        JFFAsyncOperation productLoader = skProductLoaderWithProductIdentifier(testProductIdentifier);
        
        productLoader(nil, nil, ^(SKProduct *product, NSError *error) {
            
            if (error) {
                finishBLock();
                return;
            }
            
            JFFAsyncOperationBinder srvCallback = ^JFFAsyncOperation(SKPaymentTransaction *transaction) {
                productIdentifier = transaction.payment.productIdentifier;
                return asyncOperationWithResult(@YES);
            };
            JFFAsyncOperation loader = [JFFPurchsing purcheserWithProduct:product
                                                              srvCallback:srvCallback];
            
            loader(nil, nil, ^(id result, NSError *error) {
                
                purchaseResult = result;
                finishBLock();
            });
        });
    };
    [self performAsyncRequestOnMainThreadWithBlock:testBlock
                                          selector:_cmd];
    
    GHAssertNotNil(purchaseResult, nil);
    GHAssertEqualObjects(productIdentifier, testProductIdentifier, nil);
}

@end
