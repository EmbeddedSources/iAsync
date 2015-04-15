//
//  JNSNetworkError.swift
//  Wishdates
//
//  Created by Vladimir Gorbenko on 18.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JNSNetworkError : JNetworkError {
    
    let context: JURLConnectionParams
    let nativeError: NSError
    
    public required init(context: JURLConnectionParams, nativeError: NSError) {
        
        self.context     = context
        self.nativeError = nativeError
        
        super.init(description:"")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var localizedDescription: String {
        
        return NSLocalizedString(
            "J_NETWORK_GENERIC_ERROR",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
    }
    
    public class func createJNSNetworkErrorWithContext(
        context: JURLConnectionParams, nativeError: NSError) -> JNSNetworkError {
        
        var selfType: JNSNetworkError.Type!
        
        //select class for error
        let errorClasses: [JNSNetworkError.Type] =
        [
            JNSNoInternetNetworkError.self
        ]
        
        selfType = firstMatch(errorClasses) { (object: JNSNetworkError.Type) -> Bool in
            
            return object.isMineNSNetworkError(nativeError)
        }
        
        if selfType == nil {
            
            selfType = JNSNetworkError.self
        }
        
        return selfType(context: context, nativeError: nativeError)
    }
    
    class func isMineNSNetworkError(error: NSError) -> Bool {
        return false
    }
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(context: context, nativeError: nativeError)
    }
    
    public override var errorLogDescription: String {
        
        return "\(self.dynamicType) : \(localizedDescription) nativeError:\(nativeError) context:\(context)"
    }
}
