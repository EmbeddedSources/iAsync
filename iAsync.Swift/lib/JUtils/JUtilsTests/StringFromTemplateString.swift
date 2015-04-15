//
//  StringFromTemplateString.swift
//  JUtilsTests
//
//  Created by Vladimir Gorbenko on 13.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

class StringFromTemplateString: XCTestCase {
    
    func testStringFromTemplateString() {
        
        let templateString1: NSString = "${monthCount} months for ${price}/month"
        
        let resultString1 = templateString1.localizedTemplateStringWithVariables([
            "monthCount" : 3,
            "price"      : "$23"
        ])
        
        XCTAssertEqual("3 months for $23/month", resultString1, "unexpected template result")
        
        let templateString2: NSString = "${price} months for ${monthCount}/month"
        
        let resultString2 = templateString2.localizedTemplateStringWithVariables([
            "monthCount" : 3,
            "price"      : "$23",
        ])
        
        XCTAssertEqual("$23 months for 3/month", resultString2, "unexpected template result")
        
        let templateString3: NSString = "cc ${monthCount} months for ${price}"
        
        let resultString3 = templateString3.localizedTemplateStringWithVariables([
            "monthCount" : 3,
            "price"      : "$23",
        ])
        
        XCTAssertEqual("cc 3 months for $23", resultString3, "unexpected template result")
        
        let templateString4: NSString = "${monthCount}${price}"
        
        let resultString4 = templateString4.localizedTemplateStringWithVariables([
            "monthCount" : 3,
            "price"      : "$23",
        ])
        
        XCTAssertEqual("3$23", resultString4, "unexpected template result")
        
        let templateString5: NSString = "${monthCount"
        
        let resultString5 = templateString5.localizedTemplateStringWithVariables([
            "monthCount" : 3,
        ])
        
        XCTAssertEqual("${monthCount", resultString5, "unexpected template result")
        
        let templateString6: NSString = "${monthCount}"
        
        let resultString6 = templateString6.localizedTemplateStringWithVariables([
            "monthCount2" : 3,
        ])
        
        XCTAssertEqual("${monthCount}", resultString6, "unexpected template result")
    }
}
