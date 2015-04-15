//
//  JCacheLoadImageError.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JCacheLoadImageError : JCacheError {
    
    let nativeError: NSError
    
    required public init(nativeError: NSError) {
        
        self.nativeError = nativeError
        super.init(description: "J_CACHE_LOAD_IMAGE_ERROR")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(nativeError: nativeError)
    }
    
    override public var errorLogDescription: String {
        let result = "\(self.dynamicType) : \(localizedDescription), domain : \(domain) code : \(code) nativeError: \(nativeError.errorLogDescription)"
        return result
    }
    
    public override func writeErrorWithJLogger () {
        
        jLogger.logError(errorLogDescription)
    }
}
