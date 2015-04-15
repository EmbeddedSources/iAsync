//
//  NSError+IsNetworkError.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import CFNetwork

public extension NSError {
    
    var isNetworkError: Bool {
        
        if domain != NSURLErrorDomain {
            return false
        }
        
        let type = CFNetworkErrors(rawValue: CInt(code))
        return type == CFNetworkErrors.CFURLErrorTimedOut
            || type == CFNetworkErrors.CFURLErrorCannotFindHost
            || type == CFNetworkErrors.CFURLErrorCannotConnectToHost
            || type == CFNetworkErrors.CFURLErrorNetworkConnectionLost
            || type == CFNetworkErrors.CFURLErrorNotConnectedToInternet
    }
    
    var isActiveCallError: Bool {
        
        if domain != NSURLErrorDomain {
            return false
        }
        
        let type = CFNetworkErrors(rawValue: CInt(code))
        return type == CFNetworkErrors.CFURLErrorCallIsActive
    }
}
