//
//  JCaches.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 13.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JRestKit

private var sharedCachesInstance: JCaches?

public class JCaches : NSObject {
    
    public let dbInfo: JDBInfo
    
    public class func sharedCaches() -> JCaches {
        
        if let result = sharedCachesInstance {
            return result
        }
        
        let dbInfo = JDBInfo.defaultDBInfo()
        let result = JCaches(dbInfo:dbInfo)
        sharedCachesInstance = result
        
        return result
    }
    
    public class func setSharedCaches(caches: JCaches) {
        
        sharedCachesInstance = caches
    }
    
    public init(dbInfo: JDBInfo) {
        
        self.dbInfo = dbInfo
        super.init()
        self.setupCachesWithDBInfo()
    }
    
    public class func createCacheForName(name: String, dbInfo: JDBInfo) -> JCacheDB {
        
        let cacheInfo = dbInfo.dbInfoByNames.infoByDBName(name)!
        
        return JInternalCacheDB(cacheDBInfo:cacheInfo)
    }
    
    func cacheByName(name: String) -> JCacheDB? {
        
        return cacheDbByName[name]
    }
    
    public class func thumbnailDBName() -> String {
        
        return "J_THUMBNAIL_DB"
    }
    
    func thumbnailDB() -> JCacheDB {
        
        return cacheByName(JCaches.thumbnailDBName())!
    }
    
    class func createThumbnailDB(dbInfo: JDBInfo) -> JCacheDB {
        
        return createCacheForName(JCaches.thumbnailDBName(), dbInfo: dbInfo)
    }
    
    func createThumbnailDB(dbInfo: JDBInfo? = nil) -> JCacheDB {
        
        return self.dynamicType.createCacheForName(JCaches.thumbnailDBName(), dbInfo: dbInfo ?? self.dbInfo)
    }
    
    public func migrateDBs() {
        
        for (key, db) in cacheDbByName {
            
            db.migrateDB(dbInfo)
        }
        
        dbInfo.saveCurrentDBInfoVersions()
    }
    
    private var cacheDbByName: [String:JInternalCacheDB] = [:]
    
    private func registerAndCreateCacheDBWithName(dbPropertyName: String, cacheDBInfo: JCacheDBInfo) -> JCacheDB {
        
        if let result = self.cacheDbByName[dbPropertyName] {
            
            return result
        }
        
        let result = JInternalCacheDB(cacheDBInfo:cacheDBInfo)
        result.runAutoRemoveDataSchedulerIfNeeds()
        cacheDbByName[dbPropertyName] = result
        
        return result
    }
    
    private func setupCachesWithDBInfo() {
        
        for (dbName, dbInfo_) in dbInfo.dbInfoByNames.info {
            
            self.registerAndCreateCacheDBWithName(dbName, cacheDBInfo:dbInfo_)
        }
    }
}
