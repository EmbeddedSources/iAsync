#import "asyncPaymentOperations.h"

#import "asyncSKPaymentQueue.h"
#import "asyncSKProductRequest.h"

@implementation JFFPurchsing

+ (JFFAsyncOperation)purcheserWithProductIdentifier:(NSString *)productIdentifier
                                        srvCallback:(JFFAsyncOperationBinder)srvCallback
{
    srvCallback = [srvCallback copy];
    
    JFFAsyncOperation productLoader = skProductLoaderWithProductIdentifier(productIdentifier);
    
    JFFAsyncOperationBinder paymentBinder = ^JFFAsyncOperation(SKProduct *product) {
        return [self purcheserWithProduct:product srvCallback:srvCallback];
    };
    
    return bindSequenceOfAsyncOperations(productLoader,
                                         paymentBinder,
                                         nil);
}

+ (JFFAsyncOperation)purcheserWithProduct:(SKProduct *)product
                              srvCallback:(JFFAsyncOperationBinder)srvCallback
{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    JFFAsyncOperation paymentloader = asyncOperationWithSKPayment(payment);
    
    JFFAsyncOperationBinder srvPaymentBinder = ^JFFAsyncOperation(SKPaymentTransaction *transaction) {
        
        JFFAsyncOperation srvLoader = srvCallback(transaction);
        
        JFFAsyncOperationBinder removeTransaction = ^JFFAsyncOperation(id srvResult) {
            SKPaymentQueue *queue = [SKPaymentQueue defaultQueue];
            [queue finishTransaction:transaction];
            
            return asyncOperationWithResult(srvResult);
        };
        
        return bindSequenceOfAsyncOperations(srvLoader,
                                             removeTransaction,
                                             nil);
    };
    
    return bindSequenceOfAsyncOperations(paymentloader,
                                         srvPaymentBinder,
                                         nil);
}

@end
