//
//  JJsonToolsError.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JJsonToolsError : JError {
    
    public override class func jffErrorsDomain() -> String {
        return "com.just_for_fun.library"
    }
}
