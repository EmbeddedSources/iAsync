//
//  JObjcMutableAssignArray.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 06.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JObjcMutableAssignArray : NSObject {
    
    private let mutArray = JMutableAssignArray<NSObject>()
    
    public var onRemoveObject: JSimpleBlock? {
        get {
            return mutArray.onRemoveObject
        }
        set (newValue) {
            mutArray.onRemoveObject = newValue
        }
    }

    public var array: NSArray {
        
        return mutArray.map({$0})
    }
    
    public var count: Int {
        return mutArray.count
    }
    
    public func addObject(object: AnyObject) {

        mutArray.append(object as! NSObject)
    }
    
    public func removeObjectAtIndex(index: Int) {
        
        mutArray.removeAtIndex(index)
    }
    
    public func containsObject(object: AnyObject) -> Bool {
        
        let index = mutArray.indexOfObject(object as! NSObject)
        return index != Int.max
    }
    
    public func indexOfObject(object: AnyObject) -> Int {
        
        let index = mutArray.indexOfObject(object as! NSObject)
        return index
    }
    
    public func removeObject(object: AnyObject) {
        
        mutArray.removeObject(object as! NSObject)
    }
}
