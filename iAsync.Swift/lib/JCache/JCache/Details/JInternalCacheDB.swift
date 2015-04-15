//
//  JInternalCacheDB.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 13.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JRestKit
import JUtils
import JAsync

private var autoremoveSchedulersByCacheName: [String:JTimer] = [:]

private let internalCacheDBLockObject = NSObject()

//TODO move as private to JFFCaches
internal class JInternalCacheDB : JKeyValueDB, JCacheDB {
    
    let cacheDBInfo: JCacheDBInfo
    
    init(cacheDBInfo: JCacheDBInfo) {
        
        self.cacheDBInfo = cacheDBInfo
        
        super.init(cacheFileName:cacheDBInfo.fileName)
    }
    
    private func removeOldData() {
        
        let removeRarelyAccessDataDelay = cacheDBInfo.autoRemoveByLastAccessDate
        
        if removeRarelyAccessDataDelay > 0.0 {
            
            let fromDate = NSDate().dateByAddingTimeInterval(-removeRarelyAccessDataDelay)
            
            removeRecordsToAccessDate(fromDate)
        }
        
        let bytes = Int64(cacheDBInfo.autoRemoveByMaxSizeInMB) * 1024 * 1024
        
        if bytes > 0 {
            removeRecordsWhileTotalSizeMoreThenBytes(bytes)
        }
    }
    
    func runAutoRemoveDataSchedulerIfNeeds() {
        
        synced(internalCacheDBLockObject, { () -> () in
            
            if autoremoveSchedulersByCacheName[self.cacheDBInfo.dbPropertyName] != nil {
                return
            }
            
            let timer = JTimer()
            autoremoveSchedulersByCacheName[self.cacheDBInfo.dbPropertyName] = timer
            
            let block = { (cancel: JSimpleBlock) -> () in
                
                let loadDataBlock = { () -> JResult<NSNull> in
                    
                    self.removeOldData()
                    return JResult.value(NSNull())
                }
                
                let queueName = "com.embedded_sources.dbcache.thread_to_remove_old_data"
                let loader = asyncWithSyncOperationAndQueue(loadDataBlock, queueName)
                
                let cancel = loader(
                    progressCallback: nil,
                    stateCallback: nil,
                    finishCallback: { (result: JResult<NSNull>) in
                    
                    result.onError { $0.writeErrorWithJLogger() }
                })
            }
            block({})
            
            let cancel = timer.addBlock(block, duration:3600.0, leeway:1800.0)
        })
    }
    
    //JTODO check using of migrateDB method when multithreaded
    func migrateDB(dbInfo: JDBInfo) {
        
        let currentDbInfo = dbInfo.currentDbVersionsByName
        let currVersion   = currentDbInfo?[cacheDBInfo.dbPropertyName] as? NSNumber
        
        if let currVersion = currVersion {
            
            let lastVersion    = cacheDBInfo.version
            let currentVersion = currVersion.unsignedIntegerValue
            
            if lastVersion > currentVersion {
                removeAllRecordsWithCallback(nil)
            }
        }
    }
}
