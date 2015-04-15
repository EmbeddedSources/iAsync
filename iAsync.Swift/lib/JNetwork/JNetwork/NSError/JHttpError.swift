//
//  JHttpError.swift
//  Wishdates
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JHttpError : JNetworkError {
    
    private let context: AnyObject
    private let httpCode: CFIndex
    
    @objc public required init(httpCode: CFIndex, context: AnyObject) {
        
        self.httpCode = httpCode
        self.context  = context
        
        super.init(
            description: "J_HTTP_ERROR",
            domain     : "com.just_for_fun.library.http",
            code       : httpCode)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(httpCode: httpCode, context: context)
    }
    
    func isHttpNotChangedError() -> Bool {
        
        return code == 304
    }
    
    func isServiceUnavailableError() -> Bool {
        
        return code == 503
    }
    
    func isInternalServerError() -> Bool {
        
        return code == 500
    }
    
    func isNotFoundError() -> Bool {
        
        return code == 404
    }
    
    override public var errorLogDescription: String {
        
        return "\(self.dynamicType) : \(localizedDescription) Http code:\(code) context:\(context.description)"
    }
}
