//
//  JJsonToolsTests.swift
//  JJsonToolsTests
//
//  Created by Vladimir Gorbenko on 19.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import UIKit
import XCTest

import JUtils

class JJsonToolsTests: XCTestCase {
    
    func testParseEmptyJson() {
        
        var blockResult: AnyObject?
        var blockError : NSError?
        
        let expectation = self.expectationWithDescription(nil)
        
        let data = "{}".dataUsingEncoding(NSUTF8StringEncoding)!
        let loader = asyncJsonDataParser(data)
        
        let cancel = loader(nil, nil, { (result: JResult<AnyObject>) -> () in
        
            switch result {
            case let .Value(v):
                blockResult = v.value
            case let .Error(error):
                blockError = error
            }
            expectation.fulfill()
        })
        
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        XCTAssertTrue(blockError  == nil)
        XCTAssertTrue(blockResult != nil)
        
        XCTAssertTrue(blockResult! is NSDictionary)
    }
}
