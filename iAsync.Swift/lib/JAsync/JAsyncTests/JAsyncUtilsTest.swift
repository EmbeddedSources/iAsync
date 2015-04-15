//
//  JAsyncUtilsTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 27.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class JAsyncUtilsTest: XCTestCase {
    
    func testParalelTask() {
        
        var theSameThread = false
        var theProgressOk = false
        
        let progressExpectedValue = 17
        var progressValue: Int?
        
        let finishExpectedValue = 42
        var finishValue: Int?
        
        autoreleasepool {
            
            let currentQueue = NSThread.currentThread()
            
            let progressLoadDataBlock = { (progressCallback: JAsyncProgressCallback?) -> JResult<Int> in
                
                progressCallback?(progressInfo: progressExpectedValue)
                return JResult.value(finishExpectedValue)
            }
            let loader = asyncWithSyncOperationWithProgressBlock(progressLoadDataBlock)
            
            let expectation = self.expectationWithDescription(nil)
            
            let doneCallback = { (result: JResult<Int>) -> () in
                
                theSameThread = (currentQueue == NSThread.currentThread())
                
                result.onValue { finishValue = $0 }
                
                expectation.fulfill()
            }
            
            let progressCallback = { (data: AnyObject) -> () in
                
                theProgressOk = true
                
                theSameThread = (currentQueue == NSThread.currentThread())
                
                progressValue = data as? Int
                
                if !theSameThread {
                    expectation.fulfill()
                }
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
        
        XCTAssertTrue(theSameThread)
        XCTAssertTrue(theProgressOk)
        
        XCTAssertNotNil(progressValue)
        XCTAssertEqual(progressValue!, progressExpectedValue)
        
        XCTAssertNotNil(finishValue)
        XCTAssertEqual(finishValue!, finishExpectedValue)
    }
    
    func testCancelParalelTask() {
        
        var theSameThread = false
        
        let progressExpectedValue = 17
        var progressValue: NSNumber?
        
        let finishExpectedValue = 42
        var finishError: NSError?
        
        autoreleasepool {
            
            let currentQueue = NSThread.currentThread()
            
            let progressLoadDataBlock = { (progressCallback: JAsyncProgressCallback?) -> JResult<Int> in
                
                progressCallback?(progressInfo: progressExpectedValue)
                return JResult.value(finishExpectedValue)
            }
            let loader = asyncWithSyncOperationWithProgressBlock(progressLoadDataBlock)
            
            let expectation = self.expectationWithDescription(nil)
            
            let stateCallback = { (state: JAsyncState) -> () in
                
                expectation.fulfill()
            }
            
            let doneCallback = { (result: JResult<Int>) -> () in
                
                result.onError { finishError = $0 }
                theSameThread = (currentQueue == NSThread.currentThread())
                expectation.fulfill()
            }
            
            let progressCallback = { (data: AnyObject) -> () in
                
                progressValue = data as? NSNumber
                expectation.fulfill()
            }
            
            let timerLoader = asyncWithDelay(0.1, 0.01)
            let cancel = timerLoader(nil, nil, { (result: JResult<JAsyncTimerResult>) -> () in
                
                let cancel2 = loader(progressCallback, stateCallback, doneCallback)
                cancel2(task: .Cancel)
            })
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
        
        XCTAssertNil(progressValue)
        XCTAssertNotNil(finishError)
        XCTAssertEqual(finishError!, JAsyncFinishedByCancellationError())
        XCTAssertTrue(theSameThread)
    }
    
    func testCallingOfPregressBlock() {
        
        var progressCalled = false
        
        autoreleasepool {
            
            let resultObject = NSObject()
            
            let loadDataBlock = { () -> JResult<NSObject> in
                return JResult.value(resultObject)
            }
            
            let loader = asyncWithSyncOperationAndQueue(loadDataBlock, "com.test")
            
            var resultCalled = false
            
            let expectation = self.expectationWithDescription(nil)
            
            let doneCallback = { (result: JResult<NSObject>) -> () in
                resultCalled = true
                expectation.fulfill()
            }
            
            let progressCallback = { (info: AnyObject) -> () in
                progressCalled = true//(info == resultObject)
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
        }
        
        waitForExpectationsWithTimeout(1, handler: nil)
        
        XCTAssertFalse(progressCalled)
    }
}
