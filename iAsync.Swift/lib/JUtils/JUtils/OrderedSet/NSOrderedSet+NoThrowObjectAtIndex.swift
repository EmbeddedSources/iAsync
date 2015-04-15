//
//  NSOrderedSet+NoThrowObjectAtIndex.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 09.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSOrderedSet {
    
    func noThrowObjectAtIndex(index: Int) -> AnyObject? {
        
        if count <= index {
            return nil
        }
        
        return self[index]
    }
}
