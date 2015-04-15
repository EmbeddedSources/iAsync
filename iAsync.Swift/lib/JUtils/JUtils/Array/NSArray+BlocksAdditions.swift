//
//  NSArray+BlocksAdditions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension NSMutableArray {
    
    override internal class func converToCurrentTypeMutableArray(array: NSMutableArray) -> NSMutableArray {
        return array
    }
}

public extension NSArray {
    
    internal class func converToCurrentTypeMutableArray(array: NSMutableArray) -> NSArray {
        return array.copy() as! NSArray
    }
    
    //Invokes block once for each element of self.
    //Creates a new NSArray containing the values returned by the block.
    //if error happens it is suppressed
    func forceMap(block: JOptionMappingBlock) -> NSArray {
        
        let result: NSMutableArray = NSMutableArray(capacity: count)
        
        for object : AnyObject in self {
            let newObject : AnyObject? = block(object: object)
            if let value : AnyObject = newObject {
                result.addObject(value)
            }
        }
        
        return result.copy() as! NSArray
    }
    
    //Calls block once for number from 0(zero) to (size_ - 1)
    //Creates a new NSArray containing the values returned by the block.
    //TODO make Self return type
    class func arrayWithSize(size: Int, producer: JProducerBlock) -> NSArray {
        
        let mutResult = NSMutableArray(capacity: size)
        
        for index in 0..<size {
            mutResult.addObject(producer(index: index))
        }
        
        let result = converToCurrentTypeMutableArray(mutResult)
        return result
    }
    
    //Calls block once for number from 0(zero) to (size_ - 1)
    //Creates a new NSArray containing the values returned by the block.
    //TODO make Self return type
    class func arrayWithCapacity(capacity: Int, ignoringNilsProducer: JOptionProducerBlock) -> NSArray {
        
        let result: NSMutableArray = NSMutableArray(capacity: capacity)
        
        for index in 0..<capacity {
            let object : AnyObject? = ignoringNilsProducer(index: index)
            if let value : AnyObject = object {
                result.addObject(value)
            }
        }
        
        return converToCurrentTypeMutableArray(result)
    }
    
    //Invokes the block passing in successive elements from self,
    //Creates a new NSArray containing those elements for which the block returns a YES value
    func filter(predicate: JObjcPredicateBlock) -> NSArray {
        
        return self.filterWithIndex({ (object: AnyObject, index: Int) -> Bool in
            return predicate(object: object)
        })
    }
    
    func filterWithIndex(predicate: JPredicateWithIndexBlock) -> NSArray {
        
        let indexes = self.indexesOfObjectsPassingTest({ (object: AnyObject!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Bool in
            return predicate(object: object, index: index)
        })
        
        return objectsAtIndexes(indexes)
    }
    
    //Invokes block once for each element of self.
    //Creates a new NSArray containing the values returned by the block.
    func map(block: JObjcMappingBlock) -> NSArray {
        
        let result = NSMutableArray(capacity: count)
        
        for object: AnyObject in self {
            
            let newObject : AnyObject = block(object: object)
            result.addObject(newObject)
        }
        
        return result.copy() as! NSArray
    }
    
    //Invokes block once for each element of self.
    //Creates a new NSArray containing the values returned by the block.
    //or return nil if error happens
    func map(block : JMappingWithErrorBlock, outError : NSErrorPointer) -> NSArray? {
        
        let result : NSMutableArray? = NSMutableArray(capacity: count)
        
        for object : AnyObject in self {
            
            let newObject : AnyObject? = block(object: object, outError: outError)
            if let value : AnyObject = newObject {
                result!.addObject(value)
            } else {
                return nil
            }
        }
        
        return result?.copy() as? NSArray
    }
    
    //Invokes block once for each element of self.
    //Creates a new NSArray containing the values returned by the block. Passes index of element in block as argument.
    //or return nil if error happens
    func mapWithIndex(block : JMappingWithErrorAndIndexBlock, outError : NSErrorPointer) -> NSArray? {
        
        var result: NSMutableArray? = NSMutableArray(capacity: count)
        
        self.enumerateObjectsUsingBlock({ (object: AnyObject!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> () in
            
            let newObject : AnyObject? = block(object: object, index: idx, outError: outError)
            if let value : AnyObject = newObject {
                result!.addObject(value)
            } else {
                result = nil
                if stop != nil {
                    stop.memory = true
                }
            }
        })
        
        return result?.copy() as? NSArray
    }
    
    //Invokes the block passing in successive elements from self,
    //Creates a new NSArray containing all elements of all arrays returned the block
    func flatten(block : JFlattenBlock) -> NSArray {
        
        let result = NSMutableArray()
        
        for object : AnyObject in self {
            let objectItems = block(object: object)
            result.addObjectsFromArray(objectItems as [AnyObject])
        }
        
        return result.copy() as! NSArray
    }
    
    //Invokes the block passing in successive elements from self,
    //returning a count of those elements for which the block returns a YES value
    func count(predicate : JObjcPredicateBlock) -> Int {
        
        var count = 0
        
        for object : AnyObject in self {
            if predicate(object: object) {
                ++count
            }
        }
        
        return count
    }
    
    //Invokes the block passing in successive elements from self,
    //returning the first element for which the block returns a YES value
    func firstMatch(predicate : JObjcPredicateBlock) -> AnyObject? {
        
        for object : AnyObject in self {
            if predicate(object: object) {
                return object
            }
        }
        return nil
    }
    
    //Invokes the block passing in successive elements from self,
    //returning the last element for which the block returns a YES value
    func lastMatch(predicate : JObjcPredicateBlock) -> AnyObject? {
        
        let enumerator: NSEnumerator = reverseObjectEnumerator()
        
        var object: AnyObject? = enumerator.nextObject()
        while object != nil {
            if predicate(object: object!) {
                return object
            }
            object = enumerator.nextObject()
        }
        
        return nil
    }
    
    func firstIndexOfObjectMatch(predicate : JObjcPredicateBlock) -> Int {
        var result = 0
        for object : AnyObject in self {
            if predicate(object: object) {
                return result
            }
            ++result
        }
        return Foundation.NSNotFound
    }
    
    //Invokes the block passing parallel in successive elements from self and other NSArray,
    func transformWithArray(other : NSArray, withBlock : JTransformBlock) {
        
        assert(count == other.count, "Dimensions must match to perform transform action")
        
        for itemIndex in 0..<count {
            withBlock(firstObject: self[itemIndex], secondObject: other[itemIndex])
        }
    }
    
    //Invokes the block passing parallel in successive elements from self and other NSArray,
    func devideIntoArrayWithSize(size : Int, elementIndexBlock : JElementIndexBlock) -> NSArray {
        
        assert(size > 0)
        
        let mResult = NSMutableArray.arrayWithSize(size, producer : { (index: Int) -> AnyObject in
            return NSMutableArray()
        })
        
        for object : AnyObject in self {
            let inserIndex = elementIndexBlock(object: object)
            mResult[inserIndex].addObject(object)
        }
        
        let result = mResult.map({(object: AnyObject) -> AnyObject in
            return object.copy()
        })
        
        return result
    }
    
    func any(predicate : JObjcPredicateBlock) -> Bool {
        let object : AnyObject? = firstMatch(predicate)
        return object != nil
    }
    
    func all(predicate : JObjcPredicateBlock) -> Bool {
        return !any({ (object: AnyObject) -> Bool in
            return !predicate(object: object)
        })
    }
}
