//
//  asyncSKProductRequest.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils
import StoreKit

private class JAsyncSKProductsRequestAdapter : NSObject, JAsyncInterface, SKProductsRequestDelegate {

    typealias ResultType = SKProduct
    
    private let request: SKProductsRequest
    private var finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    private var response: SKProductsResponse?
    private let productIdentifier: String
    
    init(productIdentifier: String) {
        
        self.productIdentifier = productIdentifier
        self.request           = SKProductsRequest(productIdentifiers:Set([productIdentifier]))
        
        super.init()
        
        request.delegate = self
    }
    
    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        self.finishCallback = finishCallback
        
        request.start()
    }
    
    func doTask(task: JAsyncHandlerTask) {
        
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    
        if task == .Cancel {
            request.cancel()
        }
    }
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
    
    func requestDidFinish(request: SKRequest!) {
        
        let products = response!.products as! [SKProduct]
        if products.count > 0 {
        
            var product = firstMatch(products) { (product: SKProduct) -> Bool in
                return product.productIdentifier == self.productIdentifier
            }
            
            if product == nil {
                
                let log = "requestDidFinish products does not contains product with id: \(productIdentifier)"
                jLogger.logError(log)
                product = products.last
            }
            
            finishCallback?(result: JResult.value(product!))
        } else {
        
            let invalidIdentifier = response!.invalidProductIdentifiers.last! as? String
        
            let errorClass = invalidIdentifier == productIdentifier
                ?JStoreKitInvalidProductIdentifierError.self
                :JStoreKitCanNoLoadProductError.self
        
            let error =  errorClass(productIdentifier: productIdentifier)
            finishCallback?(result: JResult.error(error))
        }
    }
    
    func request(request: SKRequest!, didFailWithError error: NSError!) {
        
        let passError = { () -> NSError in
            
            if let error = error {
                return error
            }
            
            return JSilentError(description:"SKRequest no inet connection")
        }
        finishCallback?(result: JResult.error(error))
    }
    
    @objc func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        self.response = response
    }
}

//TODO JAsyncTypes<SKRequest>.JAsync
public func skProductLoaderWithProductIdentifier(identifier: String) -> JAsyncTypes<SKProduct>.JAsync
{
    let factory = { () -> JAsyncSKProductsRequestAdapter in
        return JAsyncSKProductsRequestAdapter(productIdentifier:identifier)
    }
    return JAsyncBuilder.buildWithAdapterFactory(factory)
}
