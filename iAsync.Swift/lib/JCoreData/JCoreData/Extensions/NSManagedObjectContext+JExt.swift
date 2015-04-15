//
//  NSManagedObjectContext+JExt.swift
//  JCoreData
//
//  Created by Vladimir Gorbenko on 21.12.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import CoreData

private let key = "JCoreData.localThreadContext"

extension NSManagedObjectContext {
    
     private(set) class var localThreadContext: NSManagedObjectContext? {
    
        get {
            let thread = NSThread.currentThread()
            return thread.threadDictionary[key] as? NSManagedObjectContext
        }
        set (newValue) {
            let thread = NSThread.currentThread()
            
            if let value = newValue {
                thread.threadDictionary[key] = newValue
            } else {
                thread.threadDictionary.removeObjectForKey(key)
            }
        }
    }
}

public extension NSManagedObjectContext {
    
    func run(block: () -> Void) {
        
        let updates = { () -> () in
            
            NSManagedObjectContext.localThreadContext = self
            block()
            NSManagedObjectContext.localThreadContext = nil
        }
        
        performBlock(updates)
    }
    
    func runAndWait<R>(block: () -> R) -> R {
        
        var result: R?
        
        let updates = { () -> () in
            
            NSManagedObjectContext.localThreadContext = self
            result = block()
            NSManagedObjectContext.localThreadContext = nil
        }
        
        performBlockAndWait(updates)
        
        return result!
    }
}
