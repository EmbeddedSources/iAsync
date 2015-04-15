//
//  JStoreKitTransactionStateFailedError.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import StoreKit

internal extension NSError {

    var isItunesStoreError: Bool {
        return "Cannot connect to iTunes Store" == self.description
    }
}

public class JStoreKitTransactionStateFailedError: JStoreKitError {
   
    public let transaction: SKPaymentTransaction

    public required init(transaction: SKPaymentTransaction) {
        
        self.transaction = transaction
        super.init(description: "STORE_KIT_TRANSACTION_STATE_FAILED")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(transaction: transaction)
    }
    
    override public var errorLogDescription: String {
        
        return "\(self.dynamicType) : \(localizedDescription), domain : \(domain) code : \(code) transaction nativeError : \(transaction.error) payment : \(transaction.payment.productIdentifier)"
    }
    
    public override func writeErrorWithJLogger() {
    
        if transaction.error.isItunesStoreError {
            
            super.writeErrorToNSLog()
            return
        }
        super.writeErrorWithJLogger()
    }
}
