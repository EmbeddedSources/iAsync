//
//  NSOrderedSet+BlocksAdditions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 08.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension NSMutableOrderedSet {
    
    override internal class func converToCurrentTypeMutableOrderedSet(set: NSMutableOrderedSet) -> NSMutableOrderedSet {
        
        return set
    }
}

public extension NSOrderedSet {
    
    internal class func converToCurrentTypeMutableOrderedSet(set: NSMutableOrderedSet) -> NSOrderedSet {
        
        return set.copy() as! NSOrderedSet
    }
    
    class func setWithSize(size: Int, producer: JProducerBlock) -> NSOrderedSet {
        
        let result = NSMutableOrderedSet(capacity: size)
        
        for index in 0..<size {
            result.addObject(producer(index: index))
        }
        
        return converToCurrentTypeMutableOrderedSet(result)
    }
    
    //TODO test
    //TODO remove code duplicate
    func map(block: JObjcMappingBlock) -> NSOrderedSet {
        
        let result = NSMutableOrderedSet(capacity: count)
        
        for index in 0..<count {
            
            let newObject : AnyObject = block(object: self[index])
            result.addObject(newObject)
        }
        
        return result
    }
    
    func forceMap(block: JOptionMappingBlock) -> NSOrderedSet {
        
        let result = NSMutableOrderedSet(capacity: count)
        
        for index in 0..<count {
            let newObject : AnyObject? = block(object: self[index])
            if let value : AnyObject = newObject {
                result.addObject(value)
            }
        }
        
        return result
    }
    
    //TODO make template
    func firstMatch(predicate: JObjcPredicateBlock) -> AnyObject? {
        
        for index in 0..<count {
            let object : AnyObject = self[index]
            if predicate(object: object) {
                return object
            }
        }
        return nil
    }
    
    func any(predicate: JObjcPredicateBlock) -> Bool {
        
        let object : AnyObject? = firstMatch(predicate)
        return object != nil
    }
    
    func all(predicate: JObjcPredicateBlock) -> Bool {
        
        return !any({ (object: AnyObject) -> Bool in
            return !predicate(object: object)
        })
    }
    
    func filter(predicate: JObjcPredicateBlock) -> NSOrderedSet {
        
        let indexes = indexesOfObjectsPassingTest({ (object: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            return predicate(object: object)
        })
        return NSOrderedSet(array: objectsAtIndexes(indexes))
    }
}
