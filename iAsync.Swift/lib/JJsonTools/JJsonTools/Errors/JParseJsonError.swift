//
//  JParseJsonError.swift
//  JJsonTools
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JParseJsonError : JJsonToolsError {
    
    let nativeError: NSError
    let data: NSData
    let context: AnyObject?//TODO AnyObject should be Printable
    
    //TODO AnyObject should be Printable
    public required init(nativeError: NSError, data: NSData, context: AnyObject?) {
        
        self.nativeError = nativeError
        self.data        = data
        self.context     = context
        
        super.init(description: "PARSE_JSON_ERROR")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(nativeError: nativeError, data: data, context: context)
    }
    
    override public var errorLogDescription: String {
        
        return "\(self.dynamicType) : \(localizedDescription) context: \(context?.description) data: \(data.toString())"
    }
}
