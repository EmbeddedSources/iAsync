//
//  NSObject+OnDeallocBlock.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 10.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private var sharedObserversKey: Void?

public extension NSObject {
    
    //do not autorelease returned value !
    private func lazyOwnerships() -> NSMutableArray {
        
        if let result = objc_getAssociatedObject(self, &sharedObserversKey) as? NSMutableArray {
            return result
        }
        
        let result = NSMutableArray()
        objc_setAssociatedObject(self,
            &sharedObserversKey,
            result,
            UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        return result
    }
    
    private func ownerships() -> NSMutableArray? {
        let result: NSMutableArray? = objc_getAssociatedObject(self, &sharedObserversKey) as? NSMutableArray
        return result
    }
    
    func addOwnedObject(object: AnyObject) {
        autoreleasepool { self.lazyOwnerships().addObject(object) }
    }
    
    func removeOwnedObject(object: AnyObject) {
        autoreleasepool {
            if let ownerships = self.ownerships() {
                ownerships.removeObject(object)
            }
        }
    }
    
    func firstOwnedObjectMatch(predicate: JObjcPredicateBlock) -> AnyObject? {
        return self.ownerships()?.firstMatch(predicate)
    }
}
