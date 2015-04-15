//
//  StringFromQueryComponentsTest.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 08.02.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation
import XCTest

import JUtils

class StringFromQueryComponentsTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStringFromQueryComponentsTest() {
        
        let key1 = "a"
        let key2 = "a b"
        let key3 = "c"
        
        let value1 = ["value1"]
        let value2 = ["a", "b"]
        let value3: [String] = []
        
        let dict: [String:[String]] =
        [
            key1 : value1,
            key2 : value2,
            key3 : value3
        ]
        
        let str = XQueryComponents.toString(dict)
        
        let newDict: [String:[String]] = str.dictionaryFromQueryComponents()
        
        XCTAssertTrue(newDict.count == 3, "invalid dict size")
        
        let argValueA = newDict[key1]?.first
        
        XCTAssertTrue(value1[0] == argValueA, "invalid value for key: 'a'")
        
        let ABvalues = newDict[key2]
        
        XCTAssertTrue(ABvalues?.count == 2, "invalid value for key: 'a b'")
        
        XCTAssertTrue(firstMatch(ABvalues!, { $0 == "a" }) != nil, "ABvalues must contains 'a'")
        XCTAssertTrue(firstMatch(ABvalues!, { $0 == "b" }) != nil, "ABvalues must contains 'b'")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
