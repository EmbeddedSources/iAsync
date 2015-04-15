//
//  NSData+ToString.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSData {
    
    func toString() -> String? {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
    }
}
