//
//  NumberOfCharacterFromStringTest.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 14.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

class NumberOfCharacterFromStringTest: XCTestCase {
    
    func testNumberOfCharacterFromString() {
        
        XCTAssertEqual(0, "".numberOfCharacterFromString(""))
        
        XCTAssertEqual(0, "".numberOfCharacterFromString("1"))
        
        XCTAssertEqual(2, "11".numberOfCharacterFromString("1"))
        
        XCTAssertEqual(2, "21212".numberOfCharacterFromString("1"))
        
        XCTAssertEqual(5, "00021212000".numberOfCharacterFromString("21"))
        
        XCTAssertEqual(7, "00032123120000".numberOfCharacterFromString("213"))
    }
    
    func testNumberOfStringsFromString() {
        
        XCTAssertEqual(3, "aaa".numberOfStringsFromString("a"))
        
        XCTAssertEqual(1, "aaa".numberOfStringsFromString("aa"))
        
        XCTAssertEqual(1, "ab a".numberOfStringsFromString("ab"))
        
        XCTAssertEqual(1, "a abc".numberOfStringsFromString("abc"))
        
        XCTAssertEqual(0, "a ab c".numberOfStringsFromString("abc"))
        
        XCTAssertEqual(3, "ababab".numberOfStringsFromString("ab"))
    }
}
