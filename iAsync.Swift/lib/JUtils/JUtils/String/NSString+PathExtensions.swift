//
//  NSString+PathExtensions.swift
//  JUtils
//
//  Created by Vlafimir Gorbenko on 06.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSString {
    
    private class func pathWithSearchDirecory(directory: NSSearchPathDirectory) -> String {
        
        let pathes = NSSearchPathForDirectoriesInDomains(directory, .UserDomainMask, true) as! [String]
        return pathes[pathes.endIndex - 1]
    }
    
    class func documentsPathByAppendingPathComponent(str: String) -> String {
        
        struct Static {
            static var instance = NSString.pathWithSearchDirecory(.DocumentDirectory)
        }
        
        return Static.instance.stringByAppendingPathComponent(str)
    }
    
    class func cachesPathByAppendingPathComponent(str: String) -> String {
        
        struct Static {
            static var instance = NSString.pathWithSearchDirecory(.CachesDirectory)
        }
        
        return Static.instance.stringByAppendingPathComponent(str)
    }
}
