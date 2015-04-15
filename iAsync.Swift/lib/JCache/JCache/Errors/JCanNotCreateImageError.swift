//
//  JCanNotCreateImageError.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 04.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JCanNotCreateImageError : JCacheError {
    
    private let url: NSURL
    
    public required init(url: NSURL) {
        
        self.url = url
        super.init(description: "can not create image with given data")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(url: url)
    }
    
    override public func writeErrorWithJLogger() {}
    
    override public var errorLogDescription: String {
        return "\(self.dynamicType) : \(localizedDescription) url: \(url)"
    }
}
