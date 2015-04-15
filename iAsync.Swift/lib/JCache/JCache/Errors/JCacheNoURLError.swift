//
//  JCacheNoURLError.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JCacheNoURLError : JCacheError {
    
    init() {
        
        let str = "JFF_CACHE_NO_URL_ERROR"
        super.init(description: str)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func writeErrorWithJLogger () {}
}