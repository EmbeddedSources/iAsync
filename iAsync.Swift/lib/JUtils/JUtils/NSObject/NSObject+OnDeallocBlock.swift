//
//  NSObject+OnDeallocBlock.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSObject {
    
    func addOnDeallocBlock(block: JSimpleBlock) {
        
        addOwnedObject(JOnDeallocBlockOwner(block: block))
    }
    
    func addOnDeallocBlockHolder(blockHolder: JOnDeallocBlockOwner) {
        
        addOwnedObject(blockHolder)
    }
    
    func removeOnDeallocBlockHolder(blockHolder: JOnDeallocBlockOwner) {
        
        autoreleasepool {
            let objectToRemove = self.firstOwnedObjectMatch({ (object: AnyObject) -> Bool in
                return object === blockHolder
            }) as? JOnDeallocBlockOwner
            
            if let value = objectToRemove {
                value.block = nil
                self.removeOwnedObject(value)
            }
        }
    }
}
