//
//  JCacheDBInfo.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 31.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

//TODO remove public, it is internal
public class JCacheDBInfo : NSObject {
    
    public let dbPropertyName: String
    
    private let info: NSDictionary
    
    public var fileName: String {
        return info["fileName"]! as! String
    }
    
    public var version: Int {
        return info["version"]! as? Int ?? 0
    }
    
    public var timeToLiveInHours: NSTimeInterval {
        return info["timeToLiveInHours"] as? NSTimeInterval ?? 0.0
    }
    
    public var autoRemoveByLastAccessDate: NSTimeInterval {
        if let number = autoRemove?["lastAccessDateInHours"] as? NSTimeInterval {
            return number * 3600.0
        }
        return 0.0
    }
    
    private var autoRemove: NSDictionary? {
        return info["autoRemove"] as? NSDictionary
    }
    
    public var autoRemoveByMaxSizeInMB: Double {
        if let number = autoRemove?["maxSizeInMB"] as? NSNumber {
            return number.doubleValue
        }
        return 0.0
    }
    
    public init(plistInfo: NSDictionary, dbPropertyName: String) {
        
        self.info = plistInfo
        self.dbPropertyName = dbPropertyName
    }
}
