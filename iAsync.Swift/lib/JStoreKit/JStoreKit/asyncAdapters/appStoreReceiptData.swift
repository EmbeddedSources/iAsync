//
//  appStoreReceiptData.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 03.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils
import StoreKit

private extension NSError {

    var isCanceledPurchaseAuthorization: Bool {
        let result = "SSErrorDomain" == domain && code == 16
        return result
    }
}

private let cachedAsyncOp = JCachedAsync<String, NSData>()

private class JAsyncAppStoreReceiptData : NSObject, SKRequestDelegate, JAsyncInterface {
    
    typealias ResultType = NSData
    
    private var refreshReceiptRequest: SKReceiptRefreshRequest?
    private var finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    
    func unsubscribeFromObservervation() {
        
        if let refreshReceiptRequest = refreshReceiptRequest {
            
            refreshReceiptRequest.delegate = nil
            self.refreshReceiptRequest = nil
        }
        finishCallback = nil
    }
    
    private var receiptData: NSData? {
        if let receiptUrl = NSBundle.mainBundle().appStoreReceiptURL {
            return NSData(contentsOfURL:receiptUrl)
        }
        return nil
    }
    
    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        if let receiptData = receiptData {
        
            finishCallback(result: JResult.value(receiptData))
        } else {
        
            self.finishCallback = finishCallback
        
            let refreshReceiptRequest  = SKReceiptRefreshRequest(receiptProperties:[:])
            self.refreshReceiptRequest = refreshReceiptRequest
            refreshReceiptRequest.delegate = self
            refreshReceiptRequest.start()
        }
    }
    
    func doTask(task: JAsyncHandlerTask) {
        
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
        
        if task == .UnSubscribe {
            unsubscribeFromObservervation()
        } else {
            refreshReceiptRequest?.cancel()
            refreshReceiptRequest = nil
        }
    }

    var isForeignThreadResultCallback: Bool {
        return false
    }
    
    func requestDidFinish(request: SKRequest!) {
        
        if refreshReceiptRequest != request {
            return
        }
    
        let finishCallback = self.finishCallback
    
        unsubscribeFromObservervation()
    
        if let receiptData = receiptData {
        
            finishCallback?(result: JResult.value(receiptData))
        } else {
        
            finishCallback?(result: JResult.error(JSilentError(description:"no receipt was recieved")))
        }
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        
        if refreshReceiptRequest != request {
            return
        }
        
        let finishCallback = self.finishCallback
        
        unsubscribeFromObservervation()
        
        if let finishCallback = finishCallback {
            if error.isCanceledPurchaseAuthorization {
                
                finishCallback(result: JResult.error(JAsyncFinishedByCancellationError()))
                return
            }
            finishCallback(result: JResult.error(error))
        }
    }
}

func appStoreReceiptDataLoader() -> JAsyncTypes<NSData>.JAsync {
    
    let factory = { () -> JAsyncAppStoreReceiptData in
        return JAsyncAppStoreReceiptData()
    }
    
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey:__FUNCTION__)
}
