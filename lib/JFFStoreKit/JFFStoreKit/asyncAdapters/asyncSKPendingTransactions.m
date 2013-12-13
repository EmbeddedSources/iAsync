#import "asyncSKPendingTransactions.h"

#import "JFFStoreKitDisabledError.h"

static NSString *const mergeObject = @"c8e5abce-1ab9-11e3-9a3b-f23c91aec05e";

@interface JFFAsyncSKPendingTransactions : NSObject <
SKPaymentTransactionObserver,
JFFAsyncOperationInterface
>
@end

@implementation JFFAsyncSKPendingTransactions
{
    SKPaymentQueue *_queue;
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

+ (instancetype)newAsyncSKPendingTransactions
{
    JFFAsyncSKPendingTransactions *result = [self new];
    
    if (result) {
        result->_queue = [SKPaymentQueue defaultQueue];
        
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
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskUnsubscribe)
        [self unsubscribeFromObservervation];
}

- (void)finishWithTransactions:(NSArray *)transactions
{
    transactions = [self pendingTransactionsForTransactions:transactions]?:@[];
    
    if (_finishCallback)
        _finishCallback(transactions, nil);
}

- (NSArray *)pendingTransactionsForTransactions:(NSArray *)transactions
{
    NSArray *result = [transactions select:^BOOL(SKPaymentTransaction *transaction) {
        
        return transaction.transactionState == SKPaymentTransactionStateRestored;
    }];
    
    return result;
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (!_finishCallback) {
        return;
    }
    
    //TODO fix workaround for IOS 6.0
    [self performSelector:@selector(doNothing:) withObject:self afterDelay:1.];
    
    [self finishWithTransactions:transactions];
    [self unsubscribeFromObservervation];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    if (_finishCallback)
        _finishCallback(@[], nil);
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (_finishCallback)
        _finishCallback(nil, error);
}

@end

static JFFAsyncOperation privateAllPendingTransactionsLoader()
{
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncSKPendingTransactions newAsyncSKPendingTransactions];
    };
    
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    return [mergeObject asyncOperationMergeLoaders:loader withArgument:@(__FUNCTION__)];
}

JFFAsyncOperation allPendingTransactionsLoader()
{
    JFFAsyncOperation loader = privateAllPendingTransactionsLoader();
    
    return loader;
}
