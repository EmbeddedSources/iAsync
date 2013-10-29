#import "asyncSKPendingTransactions.h"

#import "JFFStoreKitDisabledError.h"

#import <JFFScheduler/JFFTimer.h>

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
    JFFAsyncOperationInterfaceResultHandler _handler;
    JFFTimer *_timer;
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

- (void)asyncOperationWithResultHandler:(JFFAsyncOperationInterfaceResultHandler)handler
                          cancelHandler:(JFFAsyncOperationInterfaceCancelHandler)cancelHandler
                        progressHandler:(JFFAsyncOperationInterfaceProgressHandler)progress
{
    if (![SKPaymentQueue canMakePayments]) {
        handler(nil, [JFFStoreKitDisabledError new]);
        return;
    }
    
    _handler = [handler copy];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    _timer = [JFFTimer new];
    
    __weak JFFAsyncSKPendingTransactions *weakSelf = self;
    
    JFFScheduledBlock actionBlock = ^(JFFCancelScheduledBlock cancel) {
        
        [weakSelf finishWithTransactions:@[]];
        cancel();
    };
    
    [_timer addBlock:actionBlock duration:0.2 leeway:0.02];
}

- (void)finishWithTransactions:(NSArray *)transactions
{
    transactions = [self pendingTransactionsForTransactions:transactions]?:@[];
    
    if (_handler)
        _handler(transactions, nil);
    
    _timer = nil;
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
    if (!_handler) {
        return;
    }
    
    //TODO fix workaround for IOS 6.0
    [self performSelector:@selector(doNothing:) withObject:self afterDelay:1.];
    
    [self finishWithTransactions:transactions];
    [self unsubscribeFromObservervation];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    //TODO finish here operation
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (_handler)
        _handler(nil, error);
    
    _timer = nil;
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
