//
//  NSDictionary+JExtendedDictionary.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 08.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSDictionary {
    
    func dictionaryByAddingObjectsFromDictionary(dictionary: NSDictionary) -> NSDictionary {
        
        let result = mutableCopy() as! NSMutableDictionary
        
        dictionary.enumerateKeysAndObjectsUsingBlock({ (key: AnyObject!, value: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> () in
            result[key as! NSCopying] = value
        })
        
        return result.copy() as! NSDictionary
    }
}
