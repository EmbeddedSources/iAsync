//
//  JGCDAdditions.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 21.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

private let lockObject = "0524a0b0-4bc8-47da-a1f5-6073ba5b59d9"
private var onceToken : dispatch_once_t = 0

private var dispatchByLabel = [String:dispatch_queue_t]()

public func dispatch_queue_get_or_create(label: String, attr: dispatch_queue_attr_t) -> dispatch_queue_t {
    
    return synced(lockObject) { () -> dispatch_queue_t in
        
        if let result = dispatchByLabel[label] {
            return result
        }
        
        let result = dispatch_queue_create(label, attr)
        dispatchByLabel[label] = result
        
        return result
    }
}

