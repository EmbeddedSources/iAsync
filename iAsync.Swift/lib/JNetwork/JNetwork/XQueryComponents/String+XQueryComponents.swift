//
//  String+XQueryComponents.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 13.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension String {
    
    func stringByDecodingURLQueryComponents() -> String {
        
        return stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    func stringByEncodingURLQueryComponents() -> String {
        
        //old one variant - " <>#%'\";?:@&=+$/,{}|\\^~[]`-*!()"
        let charactersToBeEscaped = ":/?&=;+!@#$()',*" as CFStringRef
        let charactersToLeaveUnescaped = "[]." as CFStringRef
        
        let str = self as NSString
        
        let result = CFURLCreateStringByAddingPercentEscapes(
            kCFAllocatorDefault,
            str as CFString,
            charactersToLeaveUnescaped,
            charactersToBeEscaped,
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) as NSString
        
        return result as String
    }
    
    func dictionaryFromQueryComponents() -> [String:[String]] {
        
        var result = [String:[String]]()
        
        for keyValuePairString in componentsSeparatedByString("&") {
            
            let keyValuePairArray = keyValuePairString.componentsSeparatedByString("=") as [String]
            
            // Verify that there is at least one key, and at least one value.  Ignore extra = signs
            if keyValuePairArray.count < 2 {
                continue
            }
            
            let key   = keyValuePairArray[0].stringByDecodingURLQueryComponents()
            let value = keyValuePairArray[1].stringByDecodingURLQueryComponents()
            
            var results: [String]! = result[key] // URL spec says that multiple values are allowed per key
            
            if results == nil {
                results = [String]()
            }
            
            results.append(value)
            result[key] = results
        }
        
        return result
    }
}
