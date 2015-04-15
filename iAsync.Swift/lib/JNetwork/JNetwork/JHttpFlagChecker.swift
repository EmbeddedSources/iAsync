//
//  JHttpFlagChecker.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

private let indexes = Set([301, 302, 303, 307])

public class JHttpFlagChecker {

    public class func isDownloadErrorFlag(statusCode: Int) -> Bool {
        
        let result =
            !isSuccessFlag (statusCode) &&
            !isRedirectFlag(statusCode)
        
        return result
    }
    
    public class func isRedirectFlag(statusCode: Int) -> Bool {
    
        return indexes.contains(statusCode)
    }
    
    public class func isSuccessFlag(statusCode: Int) -> Bool {
        return 200 == statusCode
    }
}
