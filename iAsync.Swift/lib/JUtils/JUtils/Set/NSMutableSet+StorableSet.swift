//
//  NSMutableSet+StorableSet.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO remove
public extension NSMutableSet {
    
    class func newStorableSetWithContentsOfFile(fileName: String) -> NSMutableSet? {
        
        let fullPath = fullPathWithFileName(fileName)
        if let array = NSArray(contentsOfFile: fullPath) {
            return NSMutableSet(array: array as [AnyObject])
        }
        return nil
    }
    
    //TODO make it private
    class func fullPathWithFileName(fileName: String) -> String {
        
        let result = NSString.documentsPathByAppendingPathComponent(fileName)
        return result
    }
    
    //TODO make it template
    func addAndSaveObject(object: AnyObject, fileName: String) -> Bool {
        
        addObject(object)
        return saveDataToFileWithName(fileName)
    }
    
    //TODO make it template
    func removeAndSaveObject(object: AnyObject, fileName: String) -> Bool {
        
        removeObject(object)
        return saveDataToFileWithName(fileName)
    }
    
    func saveDataToFileWithName(fileName: String) -> Bool {
        
        let array: NSArray = allObjects
        
        let fullPath = NSMutableSet.fullPathWithFileName(fileName)
        let result   = array.writeToFile(fullPath, atomically: true)
        if result {
            fullPath.addSkipBackupAttribute()
        }
        return result
    }
}
