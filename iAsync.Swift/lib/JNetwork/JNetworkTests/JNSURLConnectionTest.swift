//
//  JNSURLConnection.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 08.02.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import XCTest

import JUtils

class JNSURLConnectionTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidDownloadCompletesCorrectly() {
        
        let dataUrl      = NSURL(string: "http://httpbin.org/image/png")!
        let expectedData = NSData(contentsOfURL: dataUrl)!
        
        let loader = dataURLResponseLoader(dataUrl, nil, nil )
        
        let expectation = expectationWithDescription(nil)
        
        let cancel = loader(nil, nil, { (result: JResult<NSData>) -> () in
            
            switch result {
            case let .Value(v):
                XCTAssertEqual(v.value.length, expectedData.length, "packet mismatch")
            case let .Error(error):
                XCTFail("Unexpected error : \(error)")
            }
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10.0, handler: { (error: NSError!) -> Void in
            
            if let error = error {
                XCTFail("read timeout error : \(error)")
            }
        })
    }
    
    func testInValidDownloadCompletesWithError() {
        
        let dataURL = NSURL(string: "http://kdjsfhjkfhsdfjkdhfjkds.com")!
        let loader  = dataURLResponseLoader(dataURL, nil, nil)
        
        let expectation = expectationWithDescription(nil)
        
        let cancel = loader(nil, nil, { (result: JResult<NSData>) -> () in
            
            result.onValue { XCTFail("Unexpected result : \($0)") }
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10.0, handler: { (error: NSError!) -> Void in
            
            if let error = error {
                XCTFail("read timeout error : \(error)")
            }
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
