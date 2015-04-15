//
//  asyncSKPaymentQueue.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils
import StoreKit
import CoreFoundation

//TODO private !!!
public class JAsyncSKPaymentAdapter : NSObject, SKPaymentTransactionObserver, JAsyncInterface {
    
    public typealias ResultType = SKPaymentTransaction
    
    private let queue  : SKPaymentQueue
    private let payment: SKPayment
    private var addedToObservers = true
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
    
    init(payment: SKPayment) {
        
        self.payment = payment
        self.queue   = SKPaymentQueue.defaultQueue()
        
        super.init()
        
        self.queue.addTransactionObserver(self)
    }
    
    public var isForeignThreadResultCallback: Bool {
        return true
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
        queue.addPayment(payment)
    }
    
    public func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    
        if task == .UnSubscribe {
            unsubscribeFromObservervation()
        }
    }
    
    func ownTransactionForTransactions(transactions: [SKPaymentTransaction]) -> SKPaymentTransaction?
    {
        let transaction = firstMatch(transactions) { (transaction: SKPaymentTransaction) -> Bool in
            return self.payment.isEqual(transaction.payment)
        }
        
        return transaction
    }

    public func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        
        if self.finishCallback == nil {
            return
        }
        
        let transactionsAr = transactions as! [SKPaymentTransaction]
    
        let transaction = ownTransactionForTransactions(transactionsAr)
    
        if let transaction = transaction {
            
            //TODO fix workaround for IOS 6.0
            NSTimer.scheduledTimerWithTimeInterval(1.1, target: self, selector: Selector("doNothing:"), userInfo: nil, repeats: false)
            
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Purchased:
                unsubscribeFromObservervation()
                finishCallback?(result: JResult.value(transaction))
            case SKPaymentTransactionState.Failed:
                var error = { () -> NSError in
                    
                    if SKErrorDomain == transaction.error.domain
                        && transaction.error.code == SKErrorPaymentCancelled {
                        
                        return JAsyncFinishedByCancellationError()
                    }
                    
                    let locError = JStoreKitTransactionStateFailedError(transaction:transaction)
                    return locError
                }()
                unsubscribeFromObservervation()
                finishCallback?(result: JResult.error(error))
            case SKPaymentTransactionState.Restored:
                unsubscribeFromObservervation()
                finishCallback?(result: JResult.value(transaction))
            ////TODO !!! process SKPaymentTransactionStateDeferred also
            default:
                break
            }
        }
        // TODO call progress with SKPaymentTransactionStatePurchasing
    }
}

public func asyncWithSKPayment(payment: SKPayment) -> JAsyncTypes<SKPaymentTransaction>.JAsync
{
    let factory = { () -> JAsyncSKPaymentAdapter in
        return JAsyncSKPaymentAdapter(payment: payment)
    }
    var loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    loader = bindTrySequenceOfAsyncs(loader, { (error: NSError) -> JAsyncTypes<SKPaymentTransaction>.JAsync in
        
        if let error = error as? JStoreKitTransactionStateFailedError {
            
            let loader = trySequenceOfAsyncs(asyncFinishTransaction(error.transaction), asyncWithResult([]))
            
            let errorLoader: JAsyncTypes<SKPaymentTransaction>.JAsync = asyncWithError(error)
            return sequenceOfAsyncs(loader, errorLoader)
        }
        
        return asyncWithError(error)
    })
    
    return loader
}
