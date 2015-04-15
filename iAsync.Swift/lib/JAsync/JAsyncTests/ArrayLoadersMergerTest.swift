//
//  ArrayLoadersMergerTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 25.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class ArrayLoadersMergerTest: XCTestCase {
    
    func testNormalFinish() {
        
        weak var weakArrayLoader      : JAsyncManager<[Int]>?
        weak var weakArrayLoaderMerger: JArrayLoadersMerger<Int, Int>?
        
        autoreleasepool {
            let arrayLoader = JAsyncManager<[Int]>()
            weakArrayLoader = arrayLoader
            
            var result1 : Int?
            var result11: Int?
            var result2 : Int?
            var result21: Int?
            
            let loadersCount = 4
            
            let fullResultExpectation = self.expectationWithDescription(nil)
            
            var onFinishCallsCount = 0
            let onFinishTest = { () -> Void in
                ++onFinishCallsCount
                if onFinishCallsCount == loadersCount {
                    
                    XCTAssertNotNil(result1 )
                    XCTAssertNotNil(result11)
                    XCTAssertNotNil(result2 )
                    XCTAssertNotNil(result21)
                    XCTAssertEqual(1, result1! )
                    XCTAssertEqual(1, result11!)
                    XCTAssertEqual(2, result2! )
                    XCTAssertEqual(2, result21!)
                    fullResultExpectation.fulfill()
                }
                return ()
            }
            
            var subLoader2: JAsyncTypes<Int>.JAsync?
            
            let arrayLoaderMerger = JArrayLoadersMerger({ (keys: [Int]) -> JAsyncTypes<[Int]>.JAsync in
                
                let cancel2 = subLoader2!(nil, nil, { (result: JResult<Int>) -> () in
                    
                    result.onValue { result21 = $0 }
                    onFinishTest()
                    subLoader2 = nil
                })
                
                dispatch_async(dispatch_get_main_queue(), { () -> () in
                    arrayLoader.loaderFinishBlock!(result: JResult.value(keys))
                })
                return arrayLoader.loader
            })
            
            weakArrayLoaderMerger = arrayLoaderMerger
            
            let subLoader1 = arrayLoaderMerger.oneObjectLoader(1)
            subLoader2     = arrayLoaderMerger.oneObjectLoader(2)
            
            let cancel1 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onValue { result1 = $0 }
                onFinishTest()
            })
            
            let cancel11 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onValue { result11 = $0 }
                onFinishTest()
            })
            
            let cancel2 = subLoader2!(nil, nil, { (result: JResult<Int>) -> () in
                result.onValue { result2 = $0 }
                onFinishTest()
            })
            
            XCTAssertEqual(0, arrayLoader.loadingCount)
            XCTAssertNil(result1)
            XCTAssertNil(result2)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            XCTAssertEqual(loadersCount, onFinishCallsCount)
        }
        
        XCTAssertNil(weakArrayLoader      )
        XCTAssertNil(weakArrayLoaderMerger)
    }
    
    func testCancelOneLoaderWhenLoadingArray() {
        
        weak var weakArrayLoader      : JAsyncManager<[Int]>?
        weak var weakArrayLoaderMerger: JArrayLoadersMerger<Int, Int>?
        
        autoreleasepool {
            let arrayLoader = JAsyncManager<[Int]>()
            weakArrayLoader = arrayLoader
            
            var error1: NSError?
            var error2: NSError?
            
            let cancelError = JAsyncFinishedByCancellationError()
            
            let loadersCount = 2
            
            let fullResultExpectation = self.expectationWithDescription(nil)
            
            var onFinishCallsCount = 0
            let onFinishTest = { () -> () in
                ++onFinishCallsCount
                if onFinishCallsCount == loadersCount {
                    
                    XCTAssertNotNil(error1)
                    XCTAssertNotNil(error2)
                    XCTAssertEqual(cancelError, error1!)
                    XCTAssertEqual(cancelError, error2!)
                }
                return ()
            }
            
            let arrayLoaderMerger = JArrayLoadersMerger({ (keys: [Int]) -> JAsyncTypes<[Int]>.JAsync in
                
                return { (
                    progressCallback: JAsyncProgressCallback?,
                    stateCallback   : JAsyncChangeStateCallback?,
                    finishCallback  : JAsyncTypes<[Int]>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                    
                    fullResultExpectation.fulfill()
                    return arrayLoader.loader(progressCallback, stateCallback, finishCallback)
                }
            })
            
            weakArrayLoaderMerger = arrayLoaderMerger
            
            let subLoader1 = arrayLoaderMerger.oneObjectLoader(1)
            let subLoader2 = arrayLoaderMerger.oneObjectLoader(2)
            
            let cancel1 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error1 = $0 }
                onFinishTest()
            })
            
            let cancel2 = subLoader2(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error2 = $0 }
                onFinishTest()
            })
            
            XCTAssertEqual(0, arrayLoader.loadingCount)
            XCTAssertNil(error1)
            XCTAssertNil(error2)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            cancel2(task: .Cancel)
            
            XCTAssertEqual(loadersCount, onFinishCallsCount)
        }
        
        XCTAssertNil(weakArrayLoader      )
        XCTAssertNil(weakArrayLoaderMerger)
    }
    
    func testCancelOneLoaderBeforeLoadingArray() {
        
        weak var weakArrayLoader      : JAsyncManager<[Int]>?
        weak var weakArrayLoaderMerger: JArrayLoadersMerger<Int, Int>?
        
        autoreleasepool {
            let arrayLoader = JAsyncManager<[Int]>()
            weakArrayLoader = arrayLoader
            
            var error1: NSError?
            var error2: NSError?
            
            let cancelError = JAsyncFinishedByCancellationError()
            
            var onFinishCallsCount = 0
            let onFinishTest = { () -> () in
                ++onFinishCallsCount
                if onFinishCallsCount == 2 {
                    
                    XCTAssertNotNil(error1)
                    XCTAssertNotNil(error2)
                    XCTAssertEqual(cancelError, error1!)
                    XCTAssertEqual(cancelError, error2!)
                }
                return ()
            }
            
            let arrayLoaderMerger = JArrayLoadersMerger({ (keys: [Int]) -> JAsyncTypes<[Int]>.JAsync in
                
                return arrayLoader.loader
            })
            
            weakArrayLoaderMerger = arrayLoaderMerger
            
            let subLoader1 = arrayLoaderMerger.oneObjectLoader(1)
            let subLoader2 = arrayLoaderMerger.oneObjectLoader(2)
            
            let cancel1 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error1 = $0 }
                onFinishTest()
            })
            
            let cancel2 = subLoader2(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error2 = $0 }
                onFinishTest()
            })
            
            XCTAssertEqual(0, arrayLoader.loadingCount)
            XCTAssertNil(error1)
            XCTAssertNil(error2)
            
            cancel2(task: .Cancel)
            
            XCTAssertEqual(1, onFinishCallsCount)
            
            cancel1(task: .Cancel)
            
            XCTAssertEqual(2, onFinishCallsCount)
        }
        
        XCTAssertNil(weakArrayLoader      )
        XCTAssertNil(weakArrayLoaderMerger)
    }
    
    //test unsubscribe one loader
    func testUnsubscribeOneLoaderBeforeLoadingArray() {
        
        weak var weakArrayLoader      : JAsyncManager<[Int]>?
        weak var weakArrayLoaderMerger: JArrayLoadersMerger<Int, Int>?
        
        autoreleasepool {
            let arrayLoader = JAsyncManager<[Int]>()
            weakArrayLoader = arrayLoader
            
            var result1: NSNumber?
            var error2: NSError?
            
            let cancelError = JAsyncFinishedByUnsubscriptionError()
            
            let loadersCount = 2
            
            let fullResultExpectation = self.expectationWithDescription(nil)
            
            var onFinishCallsCount = 0
            let onFinishTest = { () -> () in
                ++onFinishCallsCount
                if onFinishCallsCount == loadersCount {
                    
                    XCTAssertNotNil(result1)
                    XCTAssertEqual(1, result1!)
                    XCTAssertNotNil(error2)
                    XCTAssertEqual(cancelError, error2!)
                    fullResultExpectation.fulfill()
                }
                return ()
            }
            
            let arrayLoaderMerger = JArrayLoadersMerger({ (keys: [Int]) -> JAsyncTypes<[Int]>.JAsync in
                
                return { (
                    progressCallback: JAsyncProgressCallback?,
                    stateCallback   : JAsyncChangeStateCallback?,
                    finishCallback  : JAsyncTypes<[Int]>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        arrayLoader.loaderFinishBlock!(result: JResult.value(keys))
                    })
                    
                    return arrayLoader.loader(progressCallback, stateCallback, finishCallback)
                }
            })
            
            weakArrayLoaderMerger = arrayLoaderMerger
            
            let subLoader1 = arrayLoaderMerger.oneObjectLoader(1)
            let subLoader2 = arrayLoaderMerger.oneObjectLoader(2)
            
            let cancel1 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onValue { result1 = $0 }
                onFinishTest()
            })
            
            let cancel2 = subLoader2(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error2 = $0 }
                onFinishTest()
            })
            
            XCTAssertEqual(0, arrayLoader.loadingCount)
            XCTAssertNil(result1)
            XCTAssertNil(error2)
            
            cancel2(task: .UnSubscribe)
            
            XCTAssertNil(result1)
            XCTAssertNotNil(error2)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            XCTAssertEqual(loadersCount, onFinishCallsCount)
        }
        
        XCTAssertNil(weakArrayLoader      )
        XCTAssertNil(weakArrayLoaderMerger)
    }
    
    func testUnsubscribeOneLoaderWhenLoadingArray() {
        
        weak var weakArrayLoader      : JAsyncManager<[Int]>?
        weak var weakArrayLoaderMerger: JArrayLoadersMerger<Int, Int>?
        
        autoreleasepool {
            let arrayLoader = JAsyncManager<[Int]>()
            weakArrayLoader = arrayLoader
            
            var result1: NSNumber?
            var error2: NSError?
            
            let cancelError = JAsyncFinishedByUnsubscriptionError()
            
            let loadersCount = 2
            
            let runLoaderExpectation = self.expectationWithDescription(nil)
            var fullResultExpectation: XCTestExpectation!
            
            var onFinishCallsCount = 0
            let onFinishTest = { () -> () in
                ++onFinishCallsCount
                if onFinishCallsCount == loadersCount {
                    
                    XCTAssertNotNil(result1)
                    XCTAssertEqual(1, result1!)
                    XCTAssertNotNil(error2)
                    XCTAssertEqual(cancelError, error2!)
                    fullResultExpectation.fulfill()
                }
                return ()
            }
            
            let arrayLoaderMerger = JArrayLoadersMerger({ (keys: [Int]) -> JAsyncTypes<[Int]>.JAsync in
                
                return { (
                    progressCallback: JAsyncProgressCallback?,
                    stateCallback   : JAsyncChangeStateCallback?,
                    finishCallback  : JAsyncTypes<[Int]>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                    
                    runLoaderExpectation.fulfill()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        arrayLoader.loaderFinishBlock!(result: JResult.value(keys))
                    })
                    
                    return arrayLoader.loader(progressCallback, stateCallback, finishCallback)
                }
            })
            
            weakArrayLoaderMerger = arrayLoaderMerger
            
            let subLoader1 = arrayLoaderMerger.oneObjectLoader(1)
            let subLoader2 = arrayLoaderMerger.oneObjectLoader(2)
            
            let cancel1 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onValue { result1 = $0 }
                onFinishTest()
            })
            
            let cancel2 = subLoader2(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error2 = $0 }
                onFinishTest()
            })
            
            XCTAssertEqual(0, arrayLoader.loadingCount)
            XCTAssertNil(result1)
            XCTAssertNil(error2)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            cancel2(task: .UnSubscribe)
            
            XCTAssertNil(result1)
            XCTAssertNotNil(error2)
            
            fullResultExpectation = self.expectationWithDescription(nil)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            XCTAssertEqual(loadersCount, onFinishCallsCount)
        }
        
        XCTAssertNil(weakArrayLoader      )
        XCTAssertNil(weakArrayLoaderMerger)
    }
    
    //native loader with error
    func testErrorFinish() {
        
        weak var weakArrayLoader      : JAsyncManager<[Int]>?
        weak var weakArrayLoaderMerger: JArrayLoadersMerger<Int, Int>?
        
        autoreleasepool {
            let arrayLoader = JAsyncManager<[Int]>()
            weakArrayLoader = arrayLoader
            
            var error1 : NSError?
            var error11: NSError?
            var error2 : NSError?
            var error21: NSError?
            
            let loadersCount = 4
            
            let fullResultExpectation = self.expectationWithDescription(nil)
            
            let testError = JError(description: "test error")
            
            var onFinishCallsCount = 0
            let onFinishTest = { () -> () in
                ++onFinishCallsCount
                if onFinishCallsCount == loadersCount {
                    
                    XCTAssertNotNil(error1 )
                    XCTAssertNotNil(error11)
                    XCTAssertNotNil(error2 )
                    XCTAssertNotNil(error21)
                    XCTAssertEqual(testError, error1! )
                    XCTAssertEqual(testError, error11!)
                    XCTAssertEqual(testError, error2! )
                    XCTAssertEqual(testError, error21!)
                    fullResultExpectation.fulfill()
                }
                return ()
            }
            
            var subLoader2: JAsyncTypes<Int>.JAsync?
            
            let arrayLoaderMerger = JArrayLoadersMerger({ (keys: [Int]) -> JAsyncTypes<[Int]>.JAsync in
                
                let cancel2 = subLoader2!(nil, nil, { (result: JResult<Int>) -> () in
                    result.onError { error21 = $0 }
                    onFinishTest()
                    subLoader2 = nil
                })
                
                dispatch_async(dispatch_get_main_queue(), {
                    arrayLoader.loaderFinishBlock!(result: JResult.error(testError))
                })
                return arrayLoader.loader
            })
            
            weakArrayLoaderMerger = arrayLoaderMerger
            
            let subLoader1 = arrayLoaderMerger.oneObjectLoader(1)
            subLoader2     = arrayLoaderMerger.oneObjectLoader(2)
            
            let cancel1 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error1 = $0 }
                onFinishTest()
            })
            
            let cancel11 = subLoader1(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error11 = $0 }
                onFinishTest()
            })
            
            let cancel2 = subLoader2!(nil, nil, { (result: JResult<Int>) -> () in
                result.onError { error2 = $0 }
                onFinishTest()
            })
            
            XCTAssertEqual(0, arrayLoader.loadingCount)
            XCTAssertNil(error1)
            XCTAssertNil(error2)
            
            self.waitForExpectationsWithTimeout(2, handler: nil)
            
            XCTAssertEqual(loadersCount, onFinishCallsCount)
        }
        
        XCTAssertNil(weakArrayLoader      )
        XCTAssertNil(weakArrayLoaderMerger)
    }
}
