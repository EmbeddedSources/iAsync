//
//  NSURL+Cookies.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSURL {

    func logCookies() {
        
        var cookiesLog = "Cookies for url: \(self)\n"
    
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookiesForURL(self) as? [NSHTTPCookie] {
            
            for cookie in cookies {
                
                cookiesLog += "Name: '\(cookie.name)'; Value: '\(cookie.value)'\n"
            }
        }
    
        NSLog(cookiesLog)
    }
    
    func removeCookies() {
        
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookiesForURL(self) as? [NSHTTPCookie]
        
        if let cookies = cookies {
            for cookie in cookies {
            
                cookieStorage.deleteCookie(cookie as NSHTTPCookie)
            }
        }
    }
}
