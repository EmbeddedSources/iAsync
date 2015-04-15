//
//  NSString+PropertyName.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 09.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO make ot private
let setterPreffix = "set"
let setterSuffix  = ":"

//TODO remove it at all
public extension NSString {
    
    func propertyGetNameFromPropertyName() -> String? {
        
        if length <= 4 || !hasSuffix(setterSuffix) || !hasPrefix(setterPreffix) {
            return nil
        }
        
        let range1    = NSMakeRange(3, 1)
        let namePart1 = substringWithRange(range1)
        let range2    = NSMakeRange(4, length - 5)
        let namePart2 = substringWithRange(range2)
        
        return namePart1.lowercaseString.stringByAppendingString(namePart2)
    }
    
    func propertySetNameForPropertyName() -> String? {
        
        if hasSuffix(setterSuffix) {
            return nil
        }
        
        let range1            = NSMakeRange(0, 1)
        let propertyNamePart1 = substringWithRange(range1).capitalizedString
        let range2            = NSMakeRange(1, length - 1)
        let propertyNamePart2 = substringWithRange(range2)
        let result            = propertyNamePart1.stringByAppendingString(propertyNamePart2)
        
        return setterPreffix.stringByAppendingString(result).stringByAppendingString(setterSuffix)
    }
}
