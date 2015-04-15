//
//  JStoreKitError.swift
//  JStoreKit
//
//  Created by Vladimir Gorbenko on 29.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JStoreKitError: JError {
   
    func jffErrorsDomain() -> String {
        
        return "com.just_for_fun.store_kit.library"
    }
}
