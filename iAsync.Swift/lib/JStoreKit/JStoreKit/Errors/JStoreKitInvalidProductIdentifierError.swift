//
//  JStoreKitInvalidProductIdentifierError.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JStoreKitInvalidProductIdentifierError: JStoreKitCanNoLoadProductError {
   
    override public var localizedDescription: String {
        return "STORE_KIT_INVALID_PRODUCT_IDENTIFIER"
    }
    
    public required init(productIdentifier: String) {
        
        super.init(productIdentifier: productIdentifier)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func writeErrorWithJLogger() {
        
        #if RELEASE
            let str = "\(self.dynamicType) : \(errorLogDescription)"
            JLogger.sharedJLogger().logError(str)
        #endif
    }
}
