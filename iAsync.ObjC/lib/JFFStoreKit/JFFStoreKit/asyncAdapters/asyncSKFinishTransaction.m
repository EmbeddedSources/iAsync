#import "asyncSKFinishTransaction.h"

#import "JFFStoreKitDisabledError.h"
#import "JFFStoreKitTransactionStateFailedError.h"

#import <JFFScheduler/JFFTimer.h>

static NSString *const mergeObject = @"002fc0c2-07c3-41c4-8296-d6f4c038655a";

typedef BOOL(^FinishTransactionPredicate)(SKPaymentTransaction *);

@interface JFFAsyncSKFinishTransaction : NSObject <
SKPaymentTransactionObserver,
JFFAsyncOperationInterface
>

@end

@implementation JFFAsyncSKFinishTransaction
{
    SKPaymentQueue *_queue;
    JFFTimer *_finishTimer;
    FinishTransactionPredicate _transactionPredicate;
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

+ (instancetype)newFAsyncSKFinishTransactionWithPredicate:(BOOL (^)(SKPaymentTransaction *))transactionPredicate
{
    JFFAsyncSKFinishTransaction *result = [self new];
    
    if (result) {
        result->_transactionPredicate = transactionPredicate;
        result->_queue                = [SKPaymentQueue defaultQueue];
        
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
    
    NSArray *transactionsToClose = [self transactionsToClose];
    
    if ([transactionsToClose count] > 0) {
        for (SKPaymentTransaction *transaction in transactionsToClose) {
            [_queue finishTransaction:transaction];
        }
        
        _finishTimer = [JFFTimer new];
        __weak JFFAsyncSKFinishTransaction *weakSelf = self;
        [_finishTimer addBlock:^(JFFCancelScheduledBlock cancel) {
            
            cancel();
            [weakSelf finishOperationWithTransactionIDs:@[]];
        } duration:3.0];
    } else {
        [self finishOperationWithTransactionIDs:@[]];
    }
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskUnSubscribe) {
        [self unsubscribeFromObservervation];
    }
}

- (void)finishOperationWithTransactionIDs:(NSArray *)transactionIDs
{
    [self unsubscribeFromObservervation];
    _finishCallback(transactionIDs, nil);
}

- (NSArray *)transactionsToClose
{
    NSArray *result = [_queue.transactions filter:^BOOL(SKPaymentTransaction *transaction) {
        return _transactionPredicate(transaction);
    }];
    result = [result filter:^BOOL(SKPaymentTransaction *transaction) {
        
        return transaction.transactionState != SKPaymentTransactionStatePurchasing;
    }];
    return result;
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSArray *transactionsToClose = [self transactionsToClose];
    if ([transactionsToClose lastObject] == nil) {
        [self finishOperationWithTransactionIDs:@[]];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSArray *transactionsToClose = [self transactionsToClose];
    
    if ([transactionsToClose lastObject] == nil) {
        [self finishOperationWithTransactionIDs:@[]];
    }
    
    for (SKPaymentTransaction *transaction in transactionsToClose) {
        
        if (SKPaymentTransactionStateFailed == transaction.transactionState) {
            if (transaction.error.code != SKErrorPaymentCancelled) {
                // Optionally, display an error here.
            }
            JFFStoreKitTransactionStateFailedError *error = [JFFStoreKitTransactionStateFailedError new];
            error.transaction = transaction;
            JFFDidFinishAsyncOperationCallback finishCallback = _finishCallback;
            [self unsubscribeFromObservervation];
            if (finishCallback) {
                finishCallback(nil, error);
            }
            return;
        }
    }
}

@end

JFFAsyncOperation asyncOperationFinishTransaction(SKPaymentTransaction *originalTransaction)
{
    NSCParameterAssert(originalTransaction.transactionState == SKPaymentTransactionStatePurchased
                       || originalTransaction.transactionState == SKPaymentTransactionStateRestored
                       || originalTransaction.transactionState == SKPaymentTransactionStateFailed
                       );
    
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        return [JFFAsyncSKFinishTransaction newFAsyncSKFinishTransactionWithPredicate:^BOOL(SKPaymentTransaction *transaction) {
            return [transaction.transactionIdentifier isEqualToString:originalTransaction.transactionIdentifier];
        }];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    id const key =
    @{
      @"cmd" : @(__FUNCTION__),
      @"transactionIdentifier" : originalTransaction.transactionIdentifier,
      };
    return [mergeObject asyncOperationMergeLoaders:loader withArgument:key];
}

JFFAsyncOperation asyncOperationFinishTransactions(NSArray *transactionIDs)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        NSSet *transactionIDsSet = [[NSSet alloc] initWithArray:transactionIDs];
        return [JFFAsyncSKFinishTransaction newFAsyncSKFinishTransactionWithPredicate:^BOOL(SKPaymentTransaction *transaction) {
            return [transactionIDsSet containsObject:transaction.transactionIdentifier];
        }];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    id const key =
    @{
      @"cmd"            : @(__FUNCTION__),
      @"transactionIDs" : [[NSSet alloc] initWithArray:transactionIDs], //TODO !!!
      };
    return [mergeObject asyncOperationMergeLoaders:loader withArgument:key];
}

JFFAsyncOperation asyncOperationFinishTransactionsForProducts(NSArray *productIDs)
{
    JFFAsyncOperationInstanceBuilder factory = ^id<JFFAsyncOperationInterface>(void) {
        return [JFFAsyncSKFinishTransaction newFAsyncSKFinishTransactionWithPredicate:^BOOL(SKPaymentTransaction *transaction) {
            return [productIDs containsObject:transaction.payment.productIdentifier];
        }];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    id const key =
    @{
      @"cmd"        : @(__FUNCTION__),
      @"productIDs" : [[NSSet alloc] initWithArray:productIDs], //TODO !!!
      };
    return [mergeObject asyncOperationMergeLoaders:loader withArgument:key];
}
