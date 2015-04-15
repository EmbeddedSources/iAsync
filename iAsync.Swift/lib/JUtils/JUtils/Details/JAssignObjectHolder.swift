//
//  JAssignObjectHolder.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 17.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JAssignObjectHolder<T: AnyObject> {
    
    private(set) var target: Unmanaged<T>
    
    public init(targetPtr: Unmanaged<T>) {
        
        self.target = targetPtr
    }
}
