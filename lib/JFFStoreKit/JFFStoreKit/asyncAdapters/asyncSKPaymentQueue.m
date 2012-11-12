#import "asyncSKPaymentQueue.h"

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
    JFFAsyncOperationInterfaceHandler         _handler;
    JFFAsyncOperationInterfaceProgressHandler _progress;
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
    if (self->_addedToObservers)
        [self->_queue removeTransactionObserver:self];
}

+ (id)newAsyncSKPaymentAdapterWithRequest:(SKPayment *)payment
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

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceHandler)handler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    [self->_queue addPayment:self->_payment];
    
    if (![SKPaymentQueue canMakePayments]) {
        //TODO create separate error
        //!!!! remove after ios 6.0
        handler(nil, [JFFError newErrorWithDescription:@"Warn the user that purchases are disabled."]);
        return;
    }
    
    self->_handler  = [handler  copy];
    self->_progress = [progress copy];
}

- (void)cancel:(BOOL)canceled
{
}

- (SKPaymentTransaction *)ownTransactionForTransactions:(NSArray *)transactions
{
    SKPaymentTransaction *transaction = [transactions firstMatch:^BOOL(SKPaymentTransaction *transaction) {
        return [self->_payment isEqual:transaction.payment];
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
            self->_handler(transaction, nil);
            [self unsubscribeFromObservervation];
            break;
        }
        case SKPaymentTransactionStateFailed:
        {
            [self->_queue finishTransaction:transaction];
            id error = [JFFStoreKitTransactionStateFailedError new];
            self->_handler(nil, error);
            [self unsubscribeFromObservervation];
            break;
        }
        case SKPaymentTransactionStateRestored:
        {
            self->_handler(transaction, nil);
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
