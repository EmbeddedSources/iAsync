//
//  JObjcMutableAssignDictionary.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JObjcMutableAssignDictionary : NSObject {
    
    private let mutDict = JMutableAssignDictionary<NSObject, NSObject>()
    
    public func objectForKey(key: AnyObject) -> AnyObject? {
        
        return self[key]
    }
    
    public func setObject(object: AnyObject?, forKey key: AnyObject) {
        
        self[key] = object
    }
    
    public subscript(key: AnyObject) -> AnyObject? {
        
        get {
            return mutDict[key as! NSObject]
        }
        set (newValue) {
            
            mutDict[key as! NSObject] = newValue as? NSObject
        }
    }
}
