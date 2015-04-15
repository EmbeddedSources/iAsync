//
//  NSMutableSet+StorableSetTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 17.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

class NSMutableSet_StorableSetTest: XCTestCase {
    
    let fileName = "some_set_data_to_test.data"
    
    func clearFS() {
        let docFileName = NSString.documentsPathByAppendingPathComponent(fileName)
        NSFileManager.defaultManager().removeItemAtPath(docFileName, error:nil)
    }
    
    override func setUp() {
        super.setUp()
        clearFS()
    }
    
    override func tearDown() {
        clearFS()
        super.tearDown()
    }
    
    func testExample() {
        
        var set1 = NSMutableSet.newStorableSetWithContentsOfFile(self.fileName)
        
        XCTAssertTrue(set1 == nil)
        
        let set2 = NSMutableSet()
        XCTAssertTrue(set2.addAndSaveObject("a", fileName: self.fileName), "ok")
        
        let set3 = NSMutableSet.newStorableSetWithContentsOfFile(self.fileName)!
        
        XCTAssertEqual(set3.count, 1, "ok")
        XCTAssertEqual(NSSet(array: ["a"]), set3, "ok")
        XCTAssertTrue(set3.removeAndSaveObject("a", fileName: self.fileName), "ok")
        
        let set4 = NSMutableSet.newStorableSetWithContentsOfFile(self.fileName)
        
        XCTAssertEqual(set3.count, 0)
    }
}
