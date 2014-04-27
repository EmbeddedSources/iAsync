#import "asyncSKPaymentQueue.h"

#import "JFFStoreKitDisabledError.h"
#import "JFFStoreKitTransactionStateFailedError.h"

#import "asyncSKFinishTransaction.h"

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
    JFFDidFinishAsyncOperationCallback _finishCallback;
}

- (void)dealloc
{
    [self unsubscribeFromObservervation];
    _finishCallback = nil;
}

- (void)doNothing:(id)objetc
{
}

- (void)unsubscribeFromObservervation
{
    if (_addedToObservers) {
        [_queue removeTransactionObserver:self];
        _addedToObservers = NO;
    }
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

- (void)asyncOperationWithResultCallback:(JFFDidFinishAsyncOperationCallback)finishCallback
                         handlerCallback:(JFFAsyncOperationChangeStateCallback)handlerCallback
                        progressCallback:(JFFAsyncOperationProgressCallback)progressCallback
{
    if (![SKPaymentQueue canMakePayments]) {
        finishCallback(nil, [JFFStoreKitDisabledError new]);
        return;
    }
    
    _finishCallback = [finishCallback copy];
    
    SKPaymentTransaction *transaction = [self ownPurchasedTransaction];
    
    if (transaction) {
        
        [self unsubscribeFromObservervation];
        _finishCallback(transaction, nil);
    } else {
        
        [_queue addPayment:_payment];
    }
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskUnSubscribe)
        [self unsubscribeFromObservervation];
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

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (!_finishCallback) {
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
            [self unsubscribeFromObservervation];
            _finishCallback(transaction, nil);
            break;
        }
        case SKPaymentTransactionStateFailed:
        {
            if (transaction.error.code != SKErrorPaymentCancelled) {
                // Optionally, display an error here.
            }
            JFFStoreKitTransactionStateFailedError *error = [JFFStoreKitTransactionStateFailedError new];
            error.transaction = transaction;
            [self unsubscribeFromObservervation];
            _finishCallback(nil, error);
            break;
        }
        case SKPaymentTransactionStateRestored:
        {
            [self unsubscribeFromObservervation];
            _finishCallback(transaction, nil);
            break;
        }
        default:
            break;
    }
    // TODO call progress with SKPaymentTransactionStatePurchasing
}

@end

JFFAsyncOperation asyncOperationWithSKPayment(SKPayment *payment)
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncSKPaymentAdapter newAsyncSKPaymentAdapterWithRequest:payment];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    loader = bindTrySequenceOfAsyncOperations(loader, ^JFFAsyncOperation(JFFStoreKitTransactionStateFailedError *error) {
        
        if (![error isKindOfClass:[JFFStoreKitTransactionStateFailedError class]]) {
            
            return asyncOperationWithError(error);
        }
        
        JFFAsyncOperation loader = trySequenceOfAsyncOperations(asyncOperationFinishTransaction(error.transaction), asyncOperationWithResult(@YES), nil);
        
        return sequenceOfAsyncOperations(loader, asyncOperationWithError(error), nil);
    }, nil);
    
    return loader;
}
