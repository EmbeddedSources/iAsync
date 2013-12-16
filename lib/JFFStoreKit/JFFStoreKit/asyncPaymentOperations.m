#import "asyncPaymentOperations.h"

#import "asyncSKPaymentQueue.h"
#import "asyncSKProductRequest.h"
#import "asyncSKFinishTransaction.h"

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
    return ^JFFCancelAsyncOperation(JFFAsyncOperationProgressHandler progressCallback,
                                    JFFCancelAsyncOperationHandler cancelCallback,
                                    JFFDidFinishAsyncOperationHandler doneCallback) {
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        JFFAsyncOperation paymentloader = asyncOperationWithSKPayment(payment);
        
        JFFAsyncOperationBinder srvPaymentBinder = ^JFFAsyncOperation(SKPaymentTransaction *transaction) {
            
            JFFAsyncOperation srvLoader = srvCallback(transaction);
            
            JFFAsyncOperationBinder removeTransaction = ^JFFAsyncOperation(id srvResult) {
                
                JFFAsyncOperation finishTransaction = asyncOperationFinishTransaction(transaction);
                return sequenceOfAsyncOperations(finishTransaction, asyncOperationWithResult(srvResult), nil);
            };
            
            return bindSequenceOfAsyncOperations(srvLoader,
                                                 removeTransaction,
                                                 nil);
        };
        
        JFFAsyncOperation loader = bindSequenceOfAsyncOperations(paymentloader,
                                                                 srvPaymentBinder,
                                                                 nil);
        
        return loader(progressCallback, cancelCallback, doneCallback);
    };
}

@end
