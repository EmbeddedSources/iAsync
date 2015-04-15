//
//  JDBInfo.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 11.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

private var dbInfoOnce: dispatch_once_t = 0
private var dbInfoInstance: JDBInfo!

public class JDBInfo : NSObject {
    
    public let dbInfoByNames: JCacheDBInfoStorage
    
    private var _currentDbVersionsByName: NSDictionary?
    var currentDbVersionsByName: NSDictionary? {
            
        if let result = _currentDbVersionsByName {
            return result
        }
            
        return synced(self, { () -> NSDictionary? in
            if let result = self._currentDbVersionsByName {
                return result
            }
                
            let path = JDBInfo.currentDBInfoFilePath()
            let currentDbInfo: NSDictionary? = NSDictionary(contentsOfFile:path)
                
            if let currentDbInfo = currentDbInfo {
                if currentDbInfo.count > 0 {
                    self._currentDbVersionsByName = currentDbInfo
                }
            }
            return self._currentDbVersionsByName
        })
    }
    
    public init(infoPath: String) {
        
        let infoDictionary = NSDictionary(contentsOfFile:infoPath)
        dbInfoByNames = JCacheDBInfoStorage(plistInfo:infoDictionary!)//TODO fix "!"
    }
    
    init(infoDictionary: NSDictionary) {
        
        dbInfoByNames = JCacheDBInfoStorage(plistInfo:infoDictionary)
    }
    
    //TODO internal?
    public class func defaultDBInfo() -> JDBInfo {
        
        struct Static {
            static let instance = Static.createJDBInfo()
            
            private static func createJDBInfo() -> JDBInfo {
                let bundle      = NSBundle(forClass: JDBInfo.self)
                let defaultPath = bundle.pathForResource("JCacheDBInfo", ofType:"plist")
                return JDBInfo(infoPath:defaultPath!)
            }
        }
        return Static.instance
    }
    
    func saveCurrentDBInfoVersions() {
        
        synced(self, { () -> () in
            
            let mutableCurrentVersions = NSMutableDictionary()
            
            for (key, info) in self.dbInfoByNames.info {
                mutableCurrentVersions[key] = info.version
            }
            
            let currentVersions: NSDictionary = mutableCurrentVersions.copy() as! NSDictionary
            
            if let currentDbVersionsByName = self.currentDbVersionsByName {
                if currentDbVersionsByName.isEqual(currentVersions) {
                    return
                }
            }
            
            self._currentDbVersionsByName = currentVersions
            
            let path = JDBInfo.currentDBInfoFilePath()
            currentVersions.writeToFile(path, atomically:true)
            path.addSkipBackupAttribute()
        })
    }
    
    class func currentDBInfoFilePath() -> String {
        return NSString.documentsPathByAppendingPathComponent("JCurrentDBVersions.data")
    }
}
