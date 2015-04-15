//
//  JStoreKitCanNoLoadProductError.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JStoreKitCanNoLoadProductError: JStoreKitError {
   
    let productIdentifier: String
    
    override public var localizedDescription: String {
        return "STORE_KIT_CAN_NOT_LOAD_PRODUCT"
    }
    
    public required init(productIdentifier: String) {
        
        self.productIdentifier = productIdentifier
        super.init(description: "")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(productIdentifier: productIdentifier)
    }
    
    override public var errorLogDescription: String {
        return "\(self.dynamicType) : \(localizedDescription) productIdentifier:\(productIdentifier)"
    }
    
    public override func writeErrorWithJLogger() {}
}
