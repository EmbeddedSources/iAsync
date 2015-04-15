//
//  NSArray+NoThrowObjectAtIndex.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSArray {
    
    //TODO remove
    func noThrowObjectAtIndex(index: Int) -> AnyObject? {
        
        if count <= index {
            return nil
        }
        
        return self[index]
    }
}
