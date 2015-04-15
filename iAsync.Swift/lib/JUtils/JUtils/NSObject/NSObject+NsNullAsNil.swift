//
//  NSObject+NsNullAsNil.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension NSNull {
    
    //TODO change on AnyObject or Object
    public override func nsNullAsNil() -> AnyObject? {
        return nil
    }
}

public extension NSObject {
    
    //TODO change on AnyObject or Object
    func nsNullAsNil() -> AnyObject? {
        return self
    }
}
