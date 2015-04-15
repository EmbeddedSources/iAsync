//
//  String+toURL.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 22.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

extension String {
    
    func toURL() -> NSURL? {
        
        return NSURL(string: self)
    }
}