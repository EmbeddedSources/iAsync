//
//  JAsyncError.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JAsyncError: JError {
    
    public override class func jffErrorsDomain() -> String {
        
        return "com.just_for_fun.jff_async_operations.library"
    }
}
