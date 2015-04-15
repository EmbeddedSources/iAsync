//
//  JStoreKitDisabledError.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JStoreKitDisabledError: JStoreKitError {
   
    public override var localizedDescription: String {
        
        let result = NSLocalizedString(
            "J_STOREKIT_PURCHASE_DISABLED_ERROR",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
        return result
    }
    
    public init() {
        
        super.init(description: "")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func writeErrorWithJLogger() {}
}
