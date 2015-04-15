//
//  JAsyncBuilderTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 26.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

private let progressValue1 = 12
private let progressValue2 = 21
private let progressValue3 = 34
private let resultValue    = 54

class AsyncClassNormalFinish : NSObject, JAsyncInterface {
    
    typealias ResultType = AnyObject
    
    var finishCallback  : JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    var stateCallback   : JAsyncChangeStateCallback?
    var progressCallback: JAsyncProgressCallback?
    
    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        self.finishCallback   = finishCallback
        self.stateCallback    = stateCallback
        self.progressCallback = progressCallback
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> () in
            self?.finish()
            return ()
        })
    }
    
    func finish() {
        
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> () in
            self?.progressCallback?(progressInfo: progressValue1)
            dispatch_async(dispatch_get_main_queue(), { () -> () in
                self?.progressCallback?(progressInfo: progressValue2)
                dispatch_async(dispatch_get_main_queue(), { () -> () in
                    
                    if let self_ = self {
                        self_.finishCallback?(result: JResult.value(resultValue))
                        self_.makeOtherCallbacksCalls()
                    }
                    return ()
                })
                return ()
            })
            return ()
        })
    }
    
    func makeOtherCallbacksCalls() {
        
        stateCallback?(state: .Suspended)
        progressCallback?(progressInfo: progressValue3)
        finishCallback?(result: JResult.value(resultValue))
    }
    
    func doTask(task: JAsyncHandlerTask) {
        
    }
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
}

class JAsyncBuilderTest: XCTestCase {
    
    func testDoubleFinishAndCallbacksCallsBeforeAndAfterFinish() {
        
        var cancel: JAsyncHandler?
        weak var weakAsyncClass: AsyncClassNormalFinish?
        
        autoreleasepool {
            
            let loader = JAsyncBuilder.buildWithAdapterFactory({ () -> AsyncClassNormalFinish in
                let result = AsyncClassNormalFinish()
                weakAsyncClass = result
                return result
            })
            
            var progressCallbackCalls = 0
            let progressCalback = { (progressInfo: AnyObject) -> () in
                
                ++progressCallbackCalls
                
                switch progressCallbackCalls {
                case 1:
                    XCTAssertEqual(progressValue1, progressInfo as Int)
                case 2:
                    XCTAssertEqual(progressValue2, progressInfo as Int)
                default:
                    break
                }
            }
            
            var finished = false
            var finishCallbackCalls = 0
            
            let fullResultExpectation = self.expectationWithDescription(nil)
            
            let finishCalback = { (result: JResult<AnyObject>) -> () in
                
                ++finishCallbackCalls
                
                XCTAssertEqual(progressCallbackCalls, 2)
                
                result.onValue { v -> Void in {
                    finished = true
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> () in
                        
                        fullResultExpectation.fulfill()
                    })
                }}
            }
            
            cancel = loader(progressCalback, nil, finishCalback)
            
            XCTAssertFalse(finished)
            XCTAssertEqual(0, finishCallbackCalls)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            cancel!(task: .Cancel)
            
            XCTAssertTrue(finished)
            XCTAssertEqual(1, finishCallbackCalls)
        }
        
        XCTAssertNil(weakAsyncClass)
    }
    
    func testCancel() {
        
        var cancel: JAsyncHandler?
        weak var weakAsyncClass: AsyncClassNormalFinish?
        
        autoreleasepool {
            
            let loader = JAsyncBuilder.buildWithAdapterFactory({ () -> AsyncClassNormalFinish in
                let result = AsyncClassNormalFinish()
                weakAsyncClass = result
                return result
            })
            
            var progressCallbackCalls = 0
            let progressCalback = { (progressInfo: AnyObject) -> () in
                
                ++progressCallbackCalls
                return ()
            }
            
            var finished = false
            var finishCallbackCalls = 0
            
            let fullResultExpectation = self.expectationWithDescription(nil)
            
            let finishCalback = { (result: JResult<AnyObject>) -> () in
                
                ++finishCallbackCalls
                
                XCTAssertEqual(progressCallbackCalls, 0)
                
                result.onError { error -> Void in
                    if error is JAsyncFinishedByCancellationError {
                        
                        finished = true
                        dispatch_async(dispatch_get_main_queue(), { () -> () in
                            
                            fullResultExpectation.fulfill()
                        })
                    }
                }
            }
            
            cancel = loader(progressCalback, nil, finishCalback)
            
            XCTAssertFalse(finished)
            XCTAssertEqual(0, finishCallbackCalls)
            
            cancel!(task: .Cancel)
            
            XCTAssertTrue(finished)
            XCTAssertEqual(1, finishCallbackCalls)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            XCTAssertTrue(finished)
            XCTAssertEqual(progressCallbackCalls, 0)
            XCTAssertEqual(1, finishCallbackCalls)
        }
        
        XCTAssertNil(weakAsyncClass)
    }
}
