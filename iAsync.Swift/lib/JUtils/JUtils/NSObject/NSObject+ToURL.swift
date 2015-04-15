//
//  NSURL+ToURL.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 07.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSObject {
    
    func toURL() -> NSURL? {
        
        if let self_ = self as? String {
            return NSURL(string: self_)
        }
        
        if let self_ = self as? NSString {
            return NSURL(string: self_ as String)
        }
        
        if let self_ = self as? NSURL {
            return self_
        }
        
        assert(false)
        return nil
    }
}
