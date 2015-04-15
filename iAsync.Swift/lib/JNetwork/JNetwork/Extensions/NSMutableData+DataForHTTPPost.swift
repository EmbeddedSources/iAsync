//
//  NSMutableData+DataForHTTPPost.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 24.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public extension NSMutableData {

    class func dataForHTTPPostWithData(data: NSData, fileName: String, parameterName: String, boundary: String) -> Self {
        
        let result = self(capacity: data.length + 512)!
        
        result.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        result.appendData("Content-Disposition: form-data; name=\"\(parameterName)\"; filename=\"\(fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        result.appendData("Content-Type: application/octet-stream\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        result.appendData(data)
        
        result.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return result
    }
    
    func appendHTTPParameters(parameters: NSDictionary, boundary: NSString) {
        
        parameters.enumerateKeysAndObjectsUsingBlock { (key: AnyObject!, value: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

            self.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            self.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            self.appendData("\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
            self.appendData("\r\n--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
}
