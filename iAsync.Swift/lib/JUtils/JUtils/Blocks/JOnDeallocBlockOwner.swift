//
//  JOnDeallocBlockOwner.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO remove inheritence from -> NSObject
//TODO should be internal
public class JOnDeallocBlockOwner : NSObject {
    
    public var block: JSimpleBlock?
    
    public init(block: JSimpleBlock) {
        
        self.block = block
    }
    
    deinit {
        if let value = self.block {
            self.block = nil
            value()
        }
    }
}
