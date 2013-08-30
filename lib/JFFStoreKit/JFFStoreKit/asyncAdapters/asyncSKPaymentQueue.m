#import "asyncSKPaymentQueue.h"

#import "JFFStoreKitDisabledError.h"
#import "JFFStoreKitTransactionStateFailedError.h"

@interface JFFAsyncSKPaymentAdapter : NSObject <
SKPaymentTransactionObserver,
JFFAsyncOperationInterface
>
@end

@implementation JFFAsyncSKPaymentAdapter
{
    SKPaymentQueue *_queue;
    SKPayment *_payment;
    BOOL _addedToObservers;
    JFFAsyncOperationInterfaceResultHandler _handler;
}

- (void)dealloc
{
    [self unsubscribeFromObservervation];
    _handler = nil;
}

- (void)doNothing:(id)objetc
{
}

- (void)unsubscribeFromObservervation
{
    if (_addedToObservers)
        [_queue removeTransactionObserver:self];
}

+ (instancetype)newAsyncSKPaymentAdapterWithRequest:(SKPayment *)payment
{
    JFFAsyncSKPaymentAdapter *result = [self new];
    
    if (result) {
        result->_payment = payment;
        result->_queue   = [SKPaymentQueue defaultQueue];
        
        [result->_queue addTransactionObserver:result];
        result->_addedToObservers = YES;
    }
    
    return result;
}

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    if (![SKPaymentQueue canMakePayments]) {
        handler(nil, [JFFStoreKitDisabledError new]);
        return;
    }
    
    _handler = [handler copy];
    
    SKPaymentTransaction *transaction = [self ownPurchasedTransaction];
    
    if (!transaction) {
        
        [_queue addPayment:_payment];
    } else {
        
        _handler(transaction, nil);
        [self unsubscribeFromObservervation];
    }
}

- (SKPaymentTransaction *)ownPurchasedTransaction
{
    //SKPayment
    SKPaymentTransaction *transaction = [_queue.transactions firstMatch:^BOOL(SKPaymentTransaction *transaction) {
        
        return transaction.transactionState == SKPaymentTransactionStatePurchased
        && [_payment.productIdentifier isEqualToString:transaction.payment.productIdentifier];
    }];
    
    return transaction;
}

- (SKPaymentTransaction *)ownTransactionForTransactions:(NSArray *)transactions
{
    SKPaymentTransaction *transaction = [transactions firstMatch:^BOOL(SKPaymentTransaction *transaction) {
        return [_payment isEqual:transaction.payment];
    }];
    
    return transaction;
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (!_handler) {
        return;
    }
    
    SKPaymentTransaction *transaction = [self ownTransactionForTransactions:transactions];
    
    if (!transaction) {
        return;
    }
    
    //TODO fix workaround for IOS 6.0
    [self performSelector:@selector(doNothing:) withObject:self afterDelay:1.];
    
    switch (transaction.transactionState)
    {
        case SKPaymentTransactionStatePurchased:
        {
            _handler(transaction, nil);
            [self unsubscribeFromObservervation];
            break;
        }
        case SKPaymentTransactionStateFailed:
        {
            [_queue finishTransaction:transaction];
            if (transaction.error.code != SKErrorPaymentCancelled) {
                // Optionally, display an error here.
            }
            JFFStoreKitTransactionStateFailedError *error = [JFFStoreKitTransactionStateFailedError new];
            _handler(nil, error);
            [self unsubscribeFromObservervation];
            break;
        }
        case SKPaymentTransactionStateRestored:
        {
            _handler(transaction, nil);
            [self unsubscribeFromObservervation];
            break;
        }
        default:
            break;
    }
    // TODO call progress with SKPaymentTransactionStatePurchasing
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
}

@end

JFFAsyncOperation asyncOperationWithSKPayment(SKPayment *payment)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncSKPaymentAdapter newAsyncSKPaymentAdapterWithRequest:payment];
    };
    return buildAsyncOperationWithAdapterFactory(factory);
}
