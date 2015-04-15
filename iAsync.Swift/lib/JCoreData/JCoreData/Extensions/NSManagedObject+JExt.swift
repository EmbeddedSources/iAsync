//
//  NSManagedObject+JExt.swift
//  JCoreData
//
//  Created by Vladimir Gorbenko on 21.12.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import CoreData

import JUtils

//TODO - https://github.com/mglagola/iOS-Extensions/blob/master/Categories/NSManagedObject%2BExtension.m

public extension NSManagedObject {
    
    class func first(sortDescriptors: [NSSortDescriptor]? = nil) -> Self? {
        
        //TODO add limit
        return fetch(self, sortDescriptors: sortDescriptors).first
    }
    
    class func fetch<T: NSManagedObject>(type: T.Type, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        
        let context = NSManagedObjectContext.localThreadContext!
        
        let entityDescription = NSEntityDescription.entityForName(className(), inManagedObjectContext: context)
        
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDescription
        
        request.sortDescriptors = sortDescriptors
        
        var error: NSError?
        if let array = context.executeFetchRequest(request, error:&error) {
            
            return array as [T]
        }
        
        //TODO log error
        return []
    }
    
    class func create() -> Self {
        return create(self)
    }
    
    private class func create<T>(type: T.Type) -> T {
        let classname = className()
        
        let context = NSManagedObjectContext.localThreadContext!
        
        let result = NSEntityDescription.insertNewObjectForEntityForName(
            classname,
            inManagedObjectContext: context) as T
        
        return result
    }
    
    private class func className() -> String {
        let classString = NSStringFromClass(self)
        // The entity is the last component of dot-separated class name:
        let components = split(classString, { $0 == "." })
        return components.last ?? classString
    }
}
