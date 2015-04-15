//
//  JAsyncWithDelayTest.swift
//  JTimer
//
//  Created by Vladimir Gorbenko on 04.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class JAsyncWithDelayTest: XCTestCase {
    
    func testCancelAsyncWithDelay() {
        
        weak var weakObject: NSObject?
        
        var cancelBlockOk  = false
        var timeDifference = 0.0
        
        autoreleasepool {
            
            let object: NSObject! = NSObject()
            weakObject = object
            
            let expectation = self.expectationWithDescription(nil)
            
            let loader = asyncWithDelay(0.2, 0.02)
            
            let progressCallback = { (data: AnyObject) -> () in
                
                expectation.fulfill()
            }
            let doneCallback = { (result: JResult<JAsyncTimerResult>) -> () in
                
                result.onError { error -> Void in
                    if error is JAsyncFinishedByCancellationError {
                        cancelBlockOk = object != nil
                    }
                }
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
            
            cancel(task: .Cancel)
            
            let startDate = NSDate()
            
            let cancelDelay = asyncWithDelay(0.3, 0.03)(nil, nil, { (result: JResult<JAsyncTimerResult>) -> () in
                
                let finishDate = NSDate()
                timeDifference = finishDate.timeIntervalSinceDate(startDate)
                expectation.fulfill()
            })
        }
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
        
        XCTAssertTrue(weakObject == nil)
        
        XCTAssertTrue(cancelBlockOk, "OK")
        XCTAssertTrue(timeDifference >= 0.3, "OK")
    }
    
    func testAsyncWithDelayTwiceCall() {
        
        weak var weakObject: NSObject?
        
        var callsCount = 0
        
        autoreleasepool {
            
            let expectation = self.expectationWithDescription(nil)
            
            let object: NSObject! = NSObject()
            weakObject = object
            
            let loader = asyncWithDelay(0.2, 0.02)
            
            let progressCallback = { (data: AnyObject) -> () in
                expectation.fulfill()
            }
            let stateCallback = { (state: JAsyncState) -> () in
                expectation.fulfill()
            }
            let doneCallback = { (result: JResult<JAsyncTimerResult>) -> () in
                
                ++callsCount
                if callsCount == 2 && object != nil {
                    expectation.fulfill()
                }
            }
            
            let cancel1 = loader(progressCallback, nil, doneCallback)
            let cancel2 = loader(progressCallback, nil, doneCallback)
        }
        
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
        
        XCTAssertTrue(weakObject == nil)
        
        XCTAssertTrue(callsCount == 2)
    }
}
