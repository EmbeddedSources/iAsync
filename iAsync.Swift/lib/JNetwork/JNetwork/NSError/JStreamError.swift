//
//  JStreamError.swift
//  Wishdates
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JStreamError : JNetworkError {
    
    let streamError: CFStreamError
    private let context: NSCopying
    
    required public init(streamError: CFStreamError, context: NSCopying) {
        
        self.streamError = streamError
        self.context     = context
        
        let domain = "com.just_for_fun.library.network.CFError(\(streamError.domain))"
        let description = "JNETWORK_CF_STREAM_ERROR"
        
        super.init(description: description, domain: domain, code: Int(streamError.error))//TODO streamError.error)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(streamError: streamError, context: context)
    }
    
    public override var errorLogDescription: String {
        
        return "\(self.dynamicType) : \(localizedDescription) nativeError domain:\(streamError.domain) error_code:\(streamError.error) context:\(context)"
    }
}
