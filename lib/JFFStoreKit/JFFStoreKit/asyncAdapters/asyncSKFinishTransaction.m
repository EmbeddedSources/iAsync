#import "asyncSKFinishTransaction.h"

#import "JFFStoreKitDisabledError.h"
#import "JFFStoreKitTransactionStateFailedError.h"

static NSString *const mergeObject = @"002fc0c2-07c3-41c4-8296-d6f4c038655a";

@interface JFFAsyncSKFinishTransaction : NSObject <
SKPaymentTransactionObserver,
JFFAsyncOperationInterface
>

@end

@implementation JFFAsyncSKFinishTransaction
{
    SKPaymentQueue *_queue;
    SKPaymentTransaction *_transaction;
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

+ (instancetype)newFAsyncSKFinishTransactionWithTransaction:(SKPaymentTransaction *)transaction
{
    JFFAsyncSKFinishTransaction *result = [self new];
    
    if (result) {
        result->_transaction = transaction;
        result->_queue       = [SKPaymentQueue defaultQueue];
        
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
    
    [_queue finishTransaction:_transaction];
    
    BOOL contains = [_queue.transactions containsObject:_transaction];
    
    if (!contains) {
    
        [self finishOperation];
    }
}

- (void)doTask:(JFFAsyncOperationHandlerTask)task
{
    NSParameterAssert(task <= JFFAsyncOperationHandlerTaskCancel);
    
    if (task == JFFAsyncOperationHandlerTaskUnsubscribe)
        [self unsubscribeFromObservervation];
}

- (void)finishOperation
{
    [self unsubscribeFromObservervation];
    _finishCallback(_transaction, nil);
}

#pragma mark SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    if ([transactions containsObject:_transaction])
        [self finishOperation];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (![queue.transactions containsObject:_transaction])
        [self finishOperation];
    
    switch (_transaction.transactionState)
    {
        case SKPaymentTransactionStateFailed:
        {
            if (_transaction.error.code != SKErrorPaymentCancelled) {
                // Optionally, display an error here.
            }
            JFFStoreKitTransactionStateFailedError *error = [JFFStoreKitTransactionStateFailedError new];
            error.transaction = _transaction;
            [self unsubscribeFromObservervation];
            _finishCallback(nil, error);
            break;
        }
        default:
            break;
    }
}

@end

JFFAsyncOperation asyncOperationFinishTransaction(SKPaymentTransaction *transaction)
{
    NSCParameterAssert(transaction.transactionState == SKPaymentTransactionStatePurchased
                       || transaction.transactionState == SKPaymentTransactionStateRestored
                       || transaction.transactionState == SKPaymentTransactionStateFailed
                       );
    
    JFFAsyncOperationInstanceBuilder factory = ^id< JFFAsyncOperationInterface >() {
        return [JFFAsyncSKFinishTransaction newFAsyncSKFinishTransactionWithTransaction:transaction];
    };
    JFFAsyncOperation loader = buildAsyncOperationWithAdapterFactory(factory);
    
    id key =
    @{
      @"cmd" : @(__FUNCTION__),
      @"transactionIdentifier" : transaction.transactionIdentifier,
      };
    return [mergeObject asyncOperationMergeLoaders:loader withArgument:key];
}
