//
//  NSNumber+FSStorableTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 17.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

let fileName = "some_number_data_to_test.data"

class NSNumber_FSStorableTest: XCTestCase {
    
    func clearFS() {
        let docFileName = NSString.documentsPathByAppendingPathComponent(fileName)
        NSFileManager.defaultManager().removeItemAtPath(docFileName, error: nil)
    }
    
    override func setUp() {
        super.setUp()
        clearFS()
    }
    
    override func tearDown() {
        clearFS()
        super.tearDown()
    }
    
    func testStorableMutableSet() {
        let number1 = NSNumber.newIntNumberWithContentsOfFile(fileName)
        
        XCTAssertNil(number1, "ok")
        
        let number2 = NSNumber(longLong: 10)
        number2.saveNumberToFile(fileName)
        
        let number3 = NSNumber.newIntNumberWithContentsOfFile(fileName)
        
        XCTAssertEqual(number3!.longLongValue, Int64(10), "ok")
    }
}
