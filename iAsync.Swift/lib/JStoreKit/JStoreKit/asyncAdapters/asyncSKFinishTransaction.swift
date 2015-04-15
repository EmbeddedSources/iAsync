//
//  asyncSKFinishTransaction.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils
import StoreKit

private let cachedAsyncOp = JCachedAsync<HashableDictionary<String,NSObject>, [SKPaymentTransaction]>()

private typealias FinishTransactionPredicate = (SKPaymentTransaction) -> Bool

private class JAsyncSKFinishTransaction : NSObject, SKPaymentTransactionObserver, JAsyncInterface {
    
    typealias ResultType = [SKPaymentTransaction]
    
    private let queue: SKPaymentQueue
    private var finishTimer: JTimer?
    private let transactionPredicate: FinishTransactionPredicate
    private var addedToObservers = true
    private var finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    
    deinit {
        unsubscribeFromObservervation()
        self.finishCallback = nil
    }
    
    func doNothing(objetc: AnyObject) {}
    
    func unsubscribeFromObservervation() {
        if addedToObservers {
            queue.removeTransactionObserver(self)
            addedToObservers = false
        }
    }
    
    init(transactionPredicate: FinishTransactionPredicate) {
        
        self.transactionPredicate = transactionPredicate
        self.queue                = SKPaymentQueue.defaultQueue()
        
        super.init()
        
        self.queue.addTransactionObserver(self)
    }
    
    var isForeignThreadResultCallback: Bool {
        return true
    }

    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        if !SKPaymentQueue.canMakePayments() {
            finishCallback(result: JResult.error(JStoreKitDisabledError()))
            return
        }
    
        self.finishCallback = finishCallback
    
        if transactionsToClose.count > 0 {
            for transaction in transactionsToClose {
                queue.finishTransaction(transaction)
            }
        
            let finishTimer = JTimer()
            self.finishTimer = finishTimer
            
            let cancel = finishTimer.addBlock( { [weak self] (cancel) -> () in
                
                cancel()
                self?.finishOperationWithTransactionIDs([])
            }, duration: 3.0)
        } else {
            finishOperationWithTransactionIDs([])
        }
    }
    
    func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
        
        if task == .UnSubscribe {
            unsubscribeFromObservervation()
        }
    }
    
    func finishOperationWithTransactionIDs(transactionIDs: [SKPaymentTransaction])
    {
        unsubscribeFromObservervation()
        finishCallback?(result: JResult.value(transactionIDs))
    }
    
    var transactionsToClose: [SKPaymentTransaction] {
    
        var result = (queue.transactions as! [SKPaymentTransaction]).filter { (transaction: SKPaymentTransaction) -> Bool in
            return self.transactionPredicate(transaction)
        }
        result = result.filter { (transaction: SKPaymentTransaction) -> Bool in
                
            return transaction.transactionState != SKPaymentTransactionState.Purchasing
        }
        return result
    }
    
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
        
        if transactionsToClose.isEmpty {
            finishOperationWithTransactionIDs([])
        }
    }
    
    @objc func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        if transactionsToClose.isEmpty {
            finishOperationWithTransactionIDs([])
        }
    
        for transaction in transactionsToClose {
        
            if SKPaymentTransactionState.Failed == transaction.transactionState {
                
                if transaction.error.code != SKErrorPaymentCancelled {
                    // Optionally, display an error here.
                }
                let error = JStoreKitTransactionStateFailedError(transaction:transaction)
                let finishCallback = self.finishCallback
                unsubscribeFromObservervation()
                finishCallback?(result: JResult.error(error))
                return
            }
        }
    }
}

func asyncFinishTransaction(originalTransaction: SKPaymentTransaction) -> JAsyncTypes<[SKPaymentTransaction]>.JAsync
{
    assert(originalTransaction.transactionState == SKPaymentTransactionState.Purchased
        || originalTransaction.transactionState == SKPaymentTransactionState.Restored
        || originalTransaction.transactionState == SKPaymentTransactionState.Failed
    )
    
    let factory = { () -> JAsyncSKFinishTransaction in
        return JAsyncSKFinishTransaction(transactionPredicate: { (transaction: SKPaymentTransaction) -> Bool in
            return transaction.transactionIdentifier == originalTransaction.transactionIdentifier
        })
    }
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    let key = HashableDictionary(dict:
    [
        "cmd" : __FUNCTION__,
        "transactionIdentifier" : originalTransaction.transactionIdentifier as NSObject,
    ])
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey: key)
}

func asyncFinishTransactions(transactionIDs: [String]) -> JAsyncTypes<[SKPaymentTransaction]>.JAsync
{
    let factory = { () -> JAsyncSKFinishTransaction in
        let transactionIDsSet = NSSet(array:transactionIDs)
        return JAsyncSKFinishTransaction(transactionPredicate: { (transaction: SKPaymentTransaction) -> Bool in
            return transactionIDsSet.containsObject(transaction.transactionIdentifier)
        })
    }
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    let key = HashableDictionary(dict:
    [
        "cmd"            : __FUNCTION__,
        "transactionIDs" : NSSet(array:transactionIDs)
    ])
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey: key)
}

public func asyncFinishTransactionsForProducts(productIDs: [String]) -> JAsyncTypes<[SKPaymentTransaction]>.JAsync
{
    let factory = { () -> JAsyncSKFinishTransaction in
        return JAsyncSKFinishTransaction(transactionPredicate: { (transaction: SKPaymentTransaction) -> Bool in
            return any(productIDs) { (productID: String) -> Bool in
                return productID == transaction.payment.productIdentifier
            }
        })
    }
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    let key = HashableDictionary(dict:
    [
        "cmd"        : __FUNCTION__,
        "productIDs" : NSSet(array:productIDs)
    ])
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey: key)
}
