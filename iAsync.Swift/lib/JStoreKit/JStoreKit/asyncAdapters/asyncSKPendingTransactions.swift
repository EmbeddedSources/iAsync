//
//  asyncSKPendingTransactions.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 03.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils
import StoreKit

private let cachedAsyncOp = JCachedAsync<String, [SKPaymentTransaction]>()

//TODO private
public class JAsyncSKPendingTransactions : NSObject, SKPaymentTransactionObserver, JAsyncInterface {
    
    public typealias ResultType = [SKPaymentTransaction]
    
    private let queue: SKPaymentQueue
    private var addedToObservers: Bool
    private var finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    
    deinit {
        unsubscribeFromObservervation()
        finishCallback = nil
    }
    
    @objc(doNothing:)//TODO remove
    public func doNothing(objetc: AnyObject) {}
    
    func unsubscribeFromObservervation() {
        if addedToObservers {
            queue.removeTransactionObserver(self)
            addedToObservers = false
        }
    }
    
    override init() {
        
        queue = SKPaymentQueue.defaultQueue()
        addedToObservers = true
        
        super.init()
        
        queue.addTransactionObserver(self)
    }
    
    public func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        if !SKPaymentQueue.canMakePayments() {
            finishCallback(result: JResult.error(JStoreKitDisabledError()))
            return
        }
    
        self.finishCallback = finishCallback
    
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    public func doTask(task: JAsyncHandlerTask) {
        
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    
        if task == .UnSubscribe {
            unsubscribeFromObservervation()
        }
    }
    
    public var isForeignThreadResultCallback: Bool {
        return false
    }
    
    func finishWithTransactions(transactions: [SKPaymentTransaction]?) {
    
        let restoredTransactions = restoredTransactionsForTransactions(transactions ?? [])
        
        self.finishCallback?(result: JResult.value(restoredTransactions))
    }
    
    public func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {}
    
    func restoredTransactionsForTransactions(transactions: [SKPaymentTransaction]) -> [SKPaymentTransaction] {
    
        let result = transactions.filter { (transaction: SKPaymentTransaction) -> Bool in
            return transaction.transactionState == SKPaymentTransactionState.Restored
        }
    
        return result
    }

    public func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        
        let self_ = self
        
        self_.finishWithTransactions(queue.transactions as? [SKPaymentTransaction])
        self_.unsubscribeFromObservervation()
    }
    
    public func paymentQueue(queue: SKPaymentQueue!, restoreCompletedTransactionsFailedWithError error: NSError!) {
        
        let self_ = self

        finishCallback?(result: JResult.error(error))

        self_.unsubscribeFromObservervation()
    }
}

public func allPendingTransactionsLoader() -> JAsyncTypes<[SKPaymentTransaction]>.JAsync {
    
    let factory = { () -> JAsyncSKPendingTransactions in
        return JAsyncSKPendingTransactions()
    }
    
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey:__FUNCTION__)
}
