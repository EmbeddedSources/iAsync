//
//  asyncPayments.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 03.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils
import StoreKit

public class JPurchsing {
    
    public class func purchaserWithProductIdentifier<SrvResp>(
        productIdentifier: String,
        srvCallback: JAsyncTypes2<String, SrvResp>.JAsyncBinder,
        recallSrvWithResult: JUtilsBlockDefinitions<SrvResp>.JPredicateBlock,
        productIDsFromSrvResponse: JUtilsBlockDefinitions2<SrvResp, [String]>.JMappingBlock) -> JAsyncTypes<SrvResp>.JAsync
    {
        let productLoader = skProductLoaderWithProductIdentifier(productIdentifier)
    
        let paymentBinder = { (product: SKProduct) -> JAsyncTypes<SrvResp>.JAsync in
        
            return self.purchaserWithProduct(
                product,
                srvCallback              : srvCallback,
                recallSrvWithResult      : recallSrvWithResult,
                productIDsFromSrvResponse: productIDsFromSrvResponse)
        }
    
        return bindSequenceOfAsyncs(productLoader, paymentBinder)
    }
    
    public class func purchaserWithProduct<SrvResp>(
        product: SKProduct,
        srvCallback: JAsyncTypes2<String, SrvResp>.JAsyncBinder,
        recallSrvWithResult: JUtilsBlockDefinitions<SrvResp>.JPredicateBlock,
        productIDsFromSrvResponse: JUtilsBlockDefinitions2<SrvResp, [String]>.JMappingBlock) -> JAsyncTypes<SrvResp>.JAsync
    {
        //TODO repeate srvLoader until buy products
        return { (
            progressCallback: JAsyncProgressCallback?,
            stateCallback: JAsyncChangeStateCallback?,
            finishCallback: JAsyncTypes<SrvResp>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            let processPayment = { (failIfNoProductsIDs: Bool) -> JAsyncTypes<SrvResp>.JAsync in
                
                //1. close previous transactions
                let binder = { (appStoreReceiptData: NSData) -> JAsyncTypes<SrvResp>.JAsync in
                    let result = appStoreReceiptData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
                    return srvCallback(result)
                }
                
                let processTransactions = bindSequenceOfAsyncs(appStoreReceiptDataLoader(), binder)
                
                let closeTranactions = { (productIDs: [String]) -> JAsyncTypes<[SKPaymentTransaction]>.JAsync in
                    
                    if failIfNoProductsIDs && productIDs.last == nil {
                        let error = JError(description: "no srv transactions - TODO fix!")
                        return asyncWithError(error)
                    }
                    
                    let noError: JAsyncTypes<[SKPaymentTransaction]>.JAsync = asyncWithResult([])
                    return trySequenceOfAsyncs(asyncFinishTransactionsForProducts(productIDs), noError)
                }
                
                let closeTransactionsAndReturnServerResult = { (nativeServerResult: SrvResp) -> JAsyncTypes<SrvResp>.JAsync in
                    
                    let productIDs = productIDsFromSrvResponse(object: nativeServerResult)
                    return sequenceOfAsyncs(closeTranactions(productIDs), asyncWithResult(nativeServerResult))
                }
                
                let srvProcessAndCloseTransactions = bindSequenceOfAsyncs(processTransactions, closeTransactionsAndReturnServerResult)
                
                return srvProcessAndCloseTransactions
            }
            
            let makePayment = { (nativeServerResult: SrvResp) -> JAsyncTypes<SrvResp>.JAsync in
                
                if !recallSrvWithResult(object: nativeServerResult) {
                    return asyncWithResult(nativeServerResult)
                }
                
                //Make payment
                let payment = SKPayment(product: product)
                let paymentLoader = asyncWithSKPayment(payment)
                
                let noError: JAsyncTypes<[SKPaymentTransaction]>.JAsync = asyncWithResult([])
                let closeTranactions = trySequenceOfAsyncs(
                    asyncFinishTransactionsForProducts([payment.productIdentifier]), noError)
                
                return sequenceOfAsyncs(closeTranactions, paymentLoader, processPayment(true))
            }
            
            let loader = bindSequenceOfAsyncs(processPayment(false), makePayment)
            
            return loader(
                progressCallback: progressCallback,
                stateCallback   : stateCallback,
                finishCallback  : finishCallback)
        }
    }
}
