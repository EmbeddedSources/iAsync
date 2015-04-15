//
//  JNetworkError.swift
//  Wishdates
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JNetworkError : JError {
    
    public override class func jffErrorsDomain() -> String {
        
        return "com.just_for_fun.network.library"
    }
}
