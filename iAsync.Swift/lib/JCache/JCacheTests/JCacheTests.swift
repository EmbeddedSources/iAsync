//
//  JCacheTests.swift
//  JCacheTests
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import UIKit

import JRestKit

import XCTest

class JCacheTests: XCTestCase {
    
    private func initializeCaches() {
        let bundle      = NSBundle(forClass: self.dynamicType)
        let defaultPath = bundle.pathForResource("JCacheDBInfo", ofType:"plist")!
        let dbInfo      = JDBInfo(infoPath:defaultPath)
        let caches      = JCaches(dbInfo:dbInfo)
        JCaches.setSharedCaches(caches)
    }
    
    private func removeFiles1() {
        
        let cacheName     = "URL_CACHES"
        let dbInfoByNames = JCaches.sharedCaches().dbInfo.dbInfoByNames
        let info          = dbInfoByNames.infoByDBName(cacheName)!
        let dbPath        = NSString.documentsPathByAppendingPathComponent(info.fileName)
        
        NSFileManager.defaultManager().removeItemAtPath(dbPath, error: nil)
    }

    private func removeFiles2() {
        
        let dbPath = NSString.documentsPathByAppendingPathComponent("cachesFileName")
        
        NSFileManager.defaultManager().removeItemAtPath(dbPath, error: nil)
    }
    
    private func removeAllFiles() {
        
        removeFiles1()
        removeFiles2()
    }
    
    override func setUp()
    {
        super.setUp()
        initializeCaches()
        removeAllFiles()
    }
    
    override func tearDown() {
        removeAllFiles()
        super.tearDown()
    }
    
    func testJFFCaches() {
        
        let cacheName = "URL_CACHES"
    
        let db: JCacheDB! = JCaches.sharedCaches().cacheByName(cacheName)
    
        XCTAssertTrue(nil != db           , "can't init database with caches")
    
        let key           = "key1"
        let stringToStore = "test Data"
        let dataToStore   = stringToStore.dataUsingEncoding(NSUTF8StringEncoding)
        var updatedDate: NSDate?
    
        let result = db.dataAndLastUpdateDateForKey(key)
    
        XCTAssertTrue(nil == result, "db should be epmty")
    
        //-------------- set Data
    
        db.setData(dataToStore, forKey: key)
    
        //-------------- read with updated data
    
        let result2 = db.dataAndLastUpdateDateForKey(key)
    
        var storedString = result2?.0.toString()
    
        println("result2: \(result2)")
        XCTAssertTrue(nil != result2               , "stored data should not be nil"           )
        XCTAssertTrue(storedString == stringToStore, "stored and readed string should be equal")
    
        //-------------- read without updated data
    
        let result3 = db.dataForKey(key)
    
        storedString = result3?.toString()
    
        XCTAssertTrue(nil != result3               , "stored data should not be nil 1"           )
        XCTAssertTrue(storedString == stringToStore, "stored and readed string should be equal 1")
    
        //-------------- remove records
    
        db.removeRecordsForKey(key)
    
        let result4 = db.dataForKey(key)
    
        storedString = result4?.toString()
    
        XCTAssertTrue(nil == result4               , "stored data should be nil 1"                 )
        XCTAssertTrue(storedString != stringToStore, "stored and readed string should not be equal")
    }
    
    func testJFFCachesWithDBDiscriptionDictionary()
    {
        let cacheName = "URL_CACHES_FROM_DICT"
    
        let dbDescription =
        [
            cacheName : [ "fileName" : "cachesFileName" ]
        ]
        
        let dbInfo = JDBInfo(infoDictionary: dbDescription)
    
        let db: JCacheDB! = JCaches.createCacheForName(cacheName, dbInfo: dbInfo)
    
        XCTAssertTrue(nil != db, "can't init database with caches")
    
        let key           = "key2"
        let stringToStore = "test Data foo"
        let dataToStore   = stringToStore.dataUsingEncoding(NSUTF8StringEncoding)
        //let updatedDate   = nil
    
        db.removeRecordsForKey(key)
        
        let result = db.dataAndLastUpdateDateForKey(key)
    
        XCTAssertTrue(result == nil)
    
        //-------------- set Data
    
        db.setData(dataToStore, forKey: key)
    
        //-------------- read with updated data
    
        let result2 = db.dataAndLastUpdateDateForKey(key)
    
        var storedString: String? = result2?.0.toString()
    
        XCTAssertTrue(nil != result2, "stored data should not be nil")
        XCTAssertTrue(storedString == stringToStore, "stored and readed string should be equal")
    
        //-------------- read without updated data
    
        let result3 = db.dataForKey(key)
    
        storedString = result3?.0.toString()
    
        XCTAssertTrue(nil != result3               , "stored data should not be nil 1"           )
        XCTAssertTrue(storedString == stringToStore, "stored and readed string should be equal 1")
    
        //-------------- remove records
    
        db.removeRecordsForKey(key)
    
        let result4 = db.dataForKey(key)
    
        storedString = result4?.0.toString()
    
        XCTAssertTrue(nil == result4               , "stored data should be nil 1"                 )
        XCTAssertTrue(storedString != stringToStore, "stored and readed string should not be equal")
    }
}
