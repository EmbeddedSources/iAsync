//
//  JFFKeyValueDB.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 11.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

private let createRecords =
"CREATE TABLE IF NOT EXISTS records ( " +
    "record_id TEXT primary key" +
    ", file_link varchar(100)" +
    ", update_time real" +
", access_time real );"

private extension String {
    
    func cacheDBFileLinkPathWithFolder(folder: String) -> String {
        
        let result = folder.stringByAppendingPathComponent(self)
        return result
    }
    
    func cacheDBFileLinkRemoveFileWithFolder(folder: String) {
        
        let path = cacheDBFileLinkPathWithFolder(folder)
        NSFileManager.defaultManager().removeItemAtPath(path, error:nil)
    }
    
    func cacheDBFileLinkSaveData(data: NSData, folder: String) {
        
        let path = cacheDBFileLinkPathWithFolder(folder)
        let url = NSURL(fileURLWithPath:path, isDirectory:false)
        data.writeToURL(url!, atomically:false)
        path.addSkipBackupAttribute()
    }
    
    func cacheDBFileLinkDataWithFolder(folder: String) -> NSData? {
        
        let path   = cacheDBFileLinkPathWithFolder(folder)
        let result = NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil)
        return result
    }
}

internal class JKeyValueDB {
    
    private let cacheFileName: String
    
    private var _db: JSQLiteDB?
    private var db: JSQLiteDB {
        if let db = _db {
                
            return db
        }
            
        let db = JSQLiteDB(dbName:cacheFileName)
            
        _db = db
            
        dispatch_barrier_async(db.dispatchQueue, {
            self.db.execQuery(createRecords)
            return ()
        })
        
        return db
    }
    
    init(cacheFileName: String) {
        
        self.cacheFileName = cacheFileName
    }
    
    func dataForKey(key: String) -> NSData? {
        
        let result = dataAndLastUpdateDateForKey(key)
        return result?.0
    }
    
    func dataAndLastUpdateDateForKey(recordId: String) -> (NSData, NSDate)? {
        
        let linkIndex: Int32 = 0
        let dateIndex: Int32 = 1
        
        let query = "SELECT file_link, update_time FROM records WHERE record_id='\(recordId)';";
        
        var result: (NSData, NSDate)?
        
        dispatch_sync(db.dispatchQueue, {
            
            //var statement: UnsafeMutablePointer<Void> = nil
            var statement: COpaquePointer = nil
            
            if self.db.prepareQuery(query, statement:&statement) {
                if bridging_sqlite3_step(statement) == BRIDGING_SQLITE_ROW {
                    
                    let str = bridging_sqlite3_column_text(statement, linkIndex)
                    let fileLink = String.fromCString(UnsafePointer<CChar>(str))!
                    let data = fileLink.cacheDBFileLinkDataWithFolder(self.db.folder)
                    
                    if let data = data {
                        let dateInetrval = bridging_sqlite3_column_double(statement, dateIndex)
                        let updateDate = NSDate(timeIntervalSince1970:dateInetrval)
                        result = (data, updateDate)
                    }
                }
                bridging_sqlite3_finalize(statement)
            }
        })
        
        if let result = result {
            updateAccessTime(recordId)
            return result
        }
        
        return nil
    }
    
    func setData(data: NSData?, forKey recordId: String) {
        
        let fileLink = fileLinkForRecordId(recordId)
        
        if let fileLink = fileLink {
            if let data = data {
                updateData(data, forRecord:recordId, fileLink:fileLink)
            } else {
                removeRecordsForRecordId(recordId, fileLink:fileLink)
            }
            return
        }
        
        if let data = data {
            addData(data, forRecord:recordId)
        }
    }
    
    private func updateData(data: NSData, forRecord recordId: String, fileLink: String) {
        
        fileLink.cacheDBFileLinkSaveData(data, folder:self.db.folder)
        
        let updateQuery = "UPDATE records SET update_time='\(currentTime)', access_time='\(currentTime)' WHERE record_id='\(recordId)';"
        
        dispatch_barrier_async(db.dispatchQueue, {
            
            var statement: COpaquePointer = nil
            if self.prepareQuery(updateQuery, statement:&statement) {
                if bridging_sqlite3_step(statement) != BRIDGING_SQLITE_DONE {
                    NSLog("\(updateQuery) - \(self.errorMessage)")
                }
                
                bridging_sqlite3_finalize(statement)
            }
        })
    }
    
    func removeRecordsToUpdateDate(date: NSDate) {
        
        removeRecordsToDate(date, dateFieldName:"update_time")
    }
    
    func removeRecordsToAccessDate(date: NSDate) {
        
        removeRecordsToDate(date, dateFieldName:"access_time")
    }
    
    func removeRecordsForKey(recordId: String) {
        
        let fileLink = fileLinkForRecordId(recordId)
        if let fileLink = fileLink {
            
            removeRecordsForRecordId(recordId, fileLink:fileLink)
        }
    }
    
    func removeRecordsWhileTotalSizeMoreThenBytes(sizeInBytes: Int64) {
        
        let selectQuery = "SELECT file_link FROM records ORDER BY access_time" //ORDER BY ASC is default
        
        dispatch_barrier_async(db.dispatchQueue, {
            
            let totalSize = self.folderSize()
            var filesRemoved: Int64 = 0
            
            if totalSize > sizeInBytes {
                
                var sizeToRemove = totalSize - sizeInBytes
                
                var statement: COpaquePointer = nil
                
                let selectQuery2 = "\(selectQuery);"
                if self.db.prepareQuery(selectQuery2, statement:&statement) {
                    
                    while bridging_sqlite3_step(statement) == BRIDGING_SQLITE_ROW && sizeToRemove > 0 {
                        
                        autoreleasepool {
                            
                            let str = bridging_sqlite3_column_text(statement, 0)
                            let fileLink = String.fromCString(UnsafePointer<CChar>(str))!
                            
                            //remove file
                            let filePath = fileLink.cacheDBFileLinkPathWithFolder(self.db.folder)
                            let fileDictionary = NSFileManager.defaultManager().attributesOfItemAtPath(filePath, error:nil)!
                            let fileSize = (fileDictionary[NSFileSize]! as! NSNumber).longLongValue
                            
                            ++filesRemoved
                            if sizeToRemove > fileSize {
                                
                                sizeToRemove -= fileSize
                            } else {
                                
                                sizeToRemove = 0
                            }
                            
                            NSFileManager.defaultManager().removeItemAtPath(filePath, error:nil)
                        }
                    }
                    bridging_sqlite3_finalize(statement)
                }
            }
            
            //////////
            
            if filesRemoved > 0 {
                
                let removeQuery = "DELETE FROM records WHERE file_link IN (\(selectQuery) LIMIT \(filesRemoved));"
                
                var statement: COpaquePointer = nil
                if self.prepareQuery(removeQuery, statement:&statement) {
                    if bridging_sqlite3_step(statement) != BRIDGING_SQLITE_DONE {
                        NSLog("\(removeQuery) - \(self.errorMessage)")
                    }
                    
                    bridging_sqlite3_finalize(statement);
                }
            }
        })
    }
    
    func removeAllRecordsWithCallback(callback: JSimpleBlock?) {
        
        ///First remove all files
        let query = "SELECT file_link FROM records;"
        
        dispatch_barrier_async(db.dispatchQueue, {
            
            var statement: COpaquePointer = nil
            if self.db.prepareQuery(query, statement:&statement) {
                while bridging_sqlite3_step(statement) == BRIDGING_SQLITE_ROW {
                    
                    autoreleasepool {
                        
                        let str = bridging_sqlite3_column_text(statement, 0)
                        let fileLink = String.fromCString(UnsafePointer<CChar>(str))!
                        
                        //JTODO remove files in separate tread, do nont wait it
                        fileLink.cacheDBFileLinkRemoveFileWithFolder(self.db.folder)
                    }
                }
                bridging_sqlite3_finalize(statement)
            }
            
            // remove records in sqlite
            let removeQuery = "DELETE * FROM records;"
            
            if self.prepareQuery(removeQuery, statement:&statement) {
                if bridging_sqlite3_step(statement) != BRIDGING_SQLITE_DONE {
                    NSLog("\(removeQuery) - \(self.errorMessage)")
                }
                
                bridging_sqlite3_finalize(statement);
            }
            
            callback?()
        })
    }
    
    private var currentTime: NSTimeInterval {
        return NSDate().timeIntervalSince1970
    }
    
    private func execQuery(sql: String) -> Bool {
        return db.execQuery(sql)
    }
    
    private func prepareQuery(sql: String, statement: UnsafeMutablePointer<COpaquePointer>) -> Bool {
        return db.prepareQuery(sql, statement: statement)
    }
    
    private var errorMessage: String? {
        return db.errorMessage
    }
    
    private func updateAccessTime(recordID: String) {
        
        dispatch_barrier_async(db.dispatchQueue, {
            self.execQuery("UPDATE records SET access_time='\(self.currentTime)' WHERE record_id='\(recordID)';")
            return ()
        })
    }
    
    private func fileLinkForRecordId(recordId: String) -> String? {
        
        let query = "SELECT file_link FROM records WHERE record_id='\(recordId)';"
        
        var result: String?
        
        dispatch_sync(db.dispatchQueue, {
            
            var statement: COpaquePointer = nil
            if self.db.prepareQuery(query, statement:&statement) {
                if bridging_sqlite3_step(statement) == BRIDGING_SQLITE_ROW {
                    let address = bridging_sqlite3_column_text(statement, 0)
                    result = String.fromCString(UnsafePointer<CChar>(address))
                }
                bridging_sqlite3_finalize(statement)
            }
        })
        
        return result
    }
    
    private func removeRecordsForRecordId(recordId: AnyObject, fileLink: String) {
        
        fileLink.cacheDBFileLinkRemoveFileWithFolder(self.db.folder)
        
        let removeQuery = "DELETE FROM records WHERE record_id='\(recordId)';"
        
        dispatch_barrier_async(db.dispatchQueue, {
            
            var statement: COpaquePointer = nil
            if self.prepareQuery(removeQuery, statement:&statement) {
                if bridging_sqlite3_step(statement) != BRIDGING_SQLITE_DONE {
                    NSLog("\(removeQuery) - \(self.errorMessage)")
                }
                
                bridging_sqlite3_finalize(statement)
            }
        })
    }
    
    private func addData(data: NSData, forRecord recordId: String) {
        
        let fileLink = NSUUID().UUIDString
        
        let addQuery = "INSERT INTO records (record_id, file_link, update_time, access_time) VALUES ('\(recordId)', '\(fileLink)', '\(currentTime)', '\(currentTime)');"
        
        dispatch_barrier_async(db.dispatchQueue, {
            
            var statement: COpaquePointer = nil
            if self.prepareQuery(addQuery, statement:&statement) {
                if bridging_sqlite3_step(statement) == BRIDGING_SQLITE_DONE {
                    fileLink.cacheDBFileLinkSaveData(data, folder:self.db.folder)
                } else {
                    NSLog("\(addQuery) - \(self.errorMessage)")
                }
                
                bridging_sqlite3_finalize(statement)
            } else {
                NSLog("\(addQuery) - \(self.errorMessage)")
            }
        })
    }
    
    //JTODO test !!!!
    private func removeRecordsToDate(date: NSDate, dateFieldName fieldName: String) {
        
        ///First remove all files
        let query = "SELECT file_link FROM records WHERE \(fieldName) < '\(date.timeIntervalSince1970)';"
        
        dispatch_barrier_async(db.dispatchQueue, {
            
            var statement: COpaquePointer = nil
            
            if self.db.prepareQuery(query, statement:&statement) {
                while bridging_sqlite3_step(statement) == BRIDGING_SQLITE_ROW {
                    
                    autoreleasepool {
                        
                        let str = bridging_sqlite3_column_text(statement, 0)
                        let fileLink = String.fromCString(UnsafePointer<CChar>(str))!
                        
                        fileLink.cacheDBFileLinkRemoveFileWithFolder(self.db.folder)
                    }
                }
                bridging_sqlite3_finalize(statement)
            }
            
            //////////
            
            let removeQuery = "DELETE FROM records WHERE \(fieldName) < '\(date.timeIntervalSince1970)';"
            
            var queryStatement: COpaquePointer = nil
            
            if self.prepareQuery(removeQuery, statement:&queryStatement) {
                if bridging_sqlite3_step(queryStatement) != BRIDGING_SQLITE_DONE {
                    NSLog("\(removeQuery) - \(self.errorMessage)")
                }
                
                bridging_sqlite3_finalize(queryStatement)
            }
        })
    }
    
    private func folderSize() -> Int64 {
        
        let folderPath  = self.db.folder
        let fileManager = NSFileManager.defaultManager()
        let filesEnumerator = fileManager.enumeratorAtPath(folderPath)
        
        var fileSize: Int64 = 0
        
        if let filesEnumerator = filesEnumerator {
            
            while let fileName = filesEnumerator.nextObject() as? String {
                
                autoreleasepool {
                    
                    let path = (folderPath as String).stringByAppendingPathComponent(fileName)
                    let fileDictionary = fileManager.attributesOfItemAtPath(path, error:nil)!
                    
                    if let size: AnyObject = fileDictionary[NSFileSize] as? NSNumber {
                        fileSize += size.longLongValue
                    }
                }
            }
        }
        
        return fileSize
    }
}

private func getOrCreateDispatchQueueForFile(file: String) -> dispatch_queue_t {
    
    let queueName = "com.jff.embedded_sources.dynamic.\(file)"
    let result = dispatch_queue_get_or_create(queueName, DISPATCH_QUEUE_CONCURRENT)
    return result
}

private class JSQLiteDB {
    
    private var db: COpaquePointer = nil
    let dispatchQueue: dispatch_queue_t
    
    private let folder: String
    
    deinit {
        bridging_sqlite3_close(db)
    }
    
    init(dbName: String) {
        
        dispatchQueue = getOrCreateDispatchQueueForFile(dbName)
        
        let dbPath = NSString.documentsPathByAppendingPathComponent(dbName)
        
        folder = (dbPath as NSString).stringByDeletingLastPathComponent
        
        dispatch_barrier_sync(dispatchQueue, {
            
            let manager = NSFileManager.defaultManager()
            
            var error: NSError?
            let created = manager.fileExistsAtPath(self.folder)
                || manager.createDirectoryAtPath(
                    self.folder,
                    withIntermediateDirectories: true,
                    attributes                 : nil ,
                    error                      : &error)
            
            if !created {
                NSLog("can not create folder: \(self.folder) error: \(error)")
                assert(created)
            }
            
            let openResult = dbPath.withCString({ (cStr: UnsafePointer<Int8>) -> Bool in
                
                let result = bridging_sqlite3_open(cStr, &self.db) == BRIDGING_SQLITE_OK
                if !result {
                    NSLog("open - \(self.errorMessage) path: \(dbPath)")
                }
                return result
            })
            if !openResult {
                assert(false)
                return
            }
            
            (dbPath as NSString).addSkipBackupAttribute()
            
            let cacheSizePragma = "PRAGMA cache_size = 1000"
            
            let pragmaResult = cacheSizePragma.withCString({ (cStr: UnsafePointer<Int8>) -> Bool in
                
                return bridging_sqlite3_exec(self.db, cStr, nil, nil, nil) == BRIDGING_SQLITE_OK
            })
            
            if !pragmaResult {
                NSLog("Error: failed to execute pragma statement: \(cacheSizePragma) with message '\(self.errorMessage)'.")
                //assert(false)
            }
        })
    }
    
    func prepareQuery(sql: String, statement: UnsafeMutablePointer<COpaquePointer>) -> Bool {
        
        return sql.withCString { (cStr: UnsafePointer<Int8>) -> Bool in
            
            return bridging_sqlite3_prepare_v2(self.db, cStr, -1, statement, nil) == BRIDGING_SQLITE_OK
        }
    }
    
    func execQuery(sql: String) -> Bool {
        
        return sql.withCString { (cStr: UnsafePointer<Int8>) -> Bool in
            
            var errorMessage: UnsafeMutablePointer<Int8> = nil
            
            if bridging_sqlite3_exec(self.db, cStr, nil, nil, &errorMessage) != BRIDGING_SQLITE_OK {
                
                let logStr = "\(sql) error: \(errorMessage)"
                NSLog(logStr)
                bridging_sqlite3_free(errorMessage)
                return false
            }
            
            return true
        }
    }
    
    var errorMessage: String? {
        return String.fromCString(bridging_sqlite3_errmsg(db))
    }
}
