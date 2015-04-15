//
//  NSString+IsEmailValid.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 08.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//
//  source: http://stackoverflow.com/questions/8198303/nsregularexpression-validate-email

import Foundation

public extension NSString {
    
    func isEmailValid() -> Bool {
        
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        
        return self as String =~ emailRegex
    }
}
