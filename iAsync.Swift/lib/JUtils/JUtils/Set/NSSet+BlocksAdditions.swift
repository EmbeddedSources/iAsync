//
//  NSSet+BlocksAdditions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension NSMutableSet {
    
    //TODO make it protected
    override internal class func converToCurrentTypeMutableSet(set: NSMutableSet) -> NSMutableSet {
        return set
    }
}

public extension NSSet {
    
    //TODO add template parameters
    
    //TODO make it protected
    internal class func converToCurrentTypeMutableSet(set: NSMutableSet) -> NSSet {
        return set.copy() as! NSSet
    }
    
    class func setWithSize(size: Int, block: JProducerBlock) -> NSSet {
        
        let result = NSMutableSet(capacity: size)
        
        for index in 0...(size - 1) {
            result.addObject(block(index: index))
        }
        
        return converToCurrentTypeMutableSet(result)
    }
    
    func map(block: JObjcMappingBlock) -> NSSet {
        
        let arrray = self.allObjects.map(block)
        return NSSet(array: arrray)
    }
    
    func forceMap(block: JOptionMappingBlock) -> NSSet {
        
        let allObjects_: NSArray = self.allObjects
        let arrray = allObjects_.forceMap(block)
        return NSSet(array: arrray as [AnyObject])
    }
    
    func filter(predicate: JObjcPredicateBlock) -> NSSet {
        
        return objectsPassingTest( {(object: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            return predicate(object: object)
        })
    }
    
    func filterArray(predicate: JObjcPredicateBlock) -> NSArray {
        
        let result = NSMutableArray(capacity: count)
        for object : AnyObject in self {
            if predicate(object: object) {
                result.addObject(object)
            }
        }
        return result.copy() as! NSArray
    }
    
    func firstMatch(predicate: JObjcPredicateBlock) -> AnyObject? {
        for object : AnyObject in self {
            if predicate(object: object) {
                return object
            }
        }
        return nil
    }
}
