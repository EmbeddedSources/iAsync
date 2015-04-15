//
//  JSimpleBlockHolder.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO remove inheritence from NSObject
public class JSimpleBlockHolder : NSObject {
    
    public var simpleBlock: JSimpleBlock?
    
    public func onceSimpleBlock() -> JSimpleBlock {
        
        return {
            
            if let block = self.simpleBlock {
                self.simpleBlock = nil
                block()
            }
        }
    }
}
