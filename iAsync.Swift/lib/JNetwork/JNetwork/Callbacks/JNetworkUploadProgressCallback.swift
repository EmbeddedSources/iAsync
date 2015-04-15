//
//  JNetworkUploadProgressCallback.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JNetworkUploadProgressCallback : NSObject, JUploadProgress {
    
    public let params: JURLConnectionParams
    public let progress: Float
    
    public var url: NSURL {
        return params.url
    }
    
    public var headers: NSDictionary? {
        return params.headers
    }
    
    public init(params: JURLConnectionParams, progress: Float) {
        
        self.params   = params
        self.progress = progress
    }
}
