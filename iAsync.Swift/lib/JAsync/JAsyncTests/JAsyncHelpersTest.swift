//
//  JAsyncHelpersTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 27.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class JAsyncHelpersTest: XCTestCase {
    
    func testCancelFirstLoader() {
        
        weak var weakNativeLoaderManager: JAsyncManager<AnyObject>?
        
        autoreleasepool {
            
            let nativeLoaderManager = JAsyncManager<AnyObject>()
            weakNativeLoaderManager = nativeLoaderManager
            
            let continueLoaderBuilder = { (result: JResult<AnyObject>) -> JAsyncTypes<AnyObject>.JAsync? in
                
                return nativeLoaderManager.loader
            }
            
            let loader = repeatAsyncWithDelayLoader(nativeLoaderManager.loader, continueLoaderBuilder, 1000)
            
            let cancel = loader(nil, nil, nil)
            cancel(task: .Cancel)
            
            XCTAssertEqual(1, nativeLoaderManager.loadingCount)
        }
        
        XCTAssertNil(weakNativeLoaderManager)
    }
    
    func testCancelTimerLoader() {
        
        weak var weakNativeLoaderManager: JAsyncManager<Int>?
        weak var weakTimerLoaderManager : JAsyncManager<Int>?
        
        autoreleasepool {
            
            let nativeLoaderManager = JAsyncManager<Int>()
            let timerLoaderManager  = JAsyncManager<Int>()
            
            weakNativeLoaderManager = nativeLoaderManager
            weakTimerLoaderManager  = timerLoaderManager
            
            var callResult: Int?
            
            let continueLoaderBuilder = { (result: JResult<Int>) -> JAsyncTypes<Int>.JAsync? in
                
                result.onValue { callResult = $0 }
                return sequenceOfAsyncs(timerLoaderManager.loader, nativeLoaderManager.loader)
            }
            
            let loader = repeatAsyncWithDelayLoader(
                nativeLoaderManager.loader, continueLoaderBuilder, 1000)
            
            let handler = loader(nil, nil, nil)
            
            let expectedResult = 23
            nativeLoaderManager.loaderFinishBlock!(result: JResult.value(expectedResult))
            
            handler(task: .Cancel)
            
            XCTAssertNotNil(callResult)
            XCTAssertEqual(callResult!, expectedResult)
            
            XCTAssertEqual(1, nativeLoaderManager.loadingCount)
            XCTAssertEqual(1, timerLoaderManager.loadingCount )
        }
        
        XCTAssertNil(weakNativeLoaderManager)
        XCTAssertNil(weakTimerLoaderManager )
    }
    
    func testCallThreeTimesNativeLoader() {
        
        weak var weakNativeLoaderManager: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let nativeLoaderManager = JAsyncManager<Int>()
            weakNativeLoaderManager = nativeLoaderManager
            
            nativeLoaderManager.finishAtLoadingResult = 17
            
            let continueLoaderBuilder = { (result: JResult<Int>) -> JAsyncTypes<Int>.JAsync? in
                
                switch result {
                case let .Value(v):
                    return nativeLoaderManager.loader
                default:
                    return nil
                }
            }
            
            let loader = repeatAsyncWithDelayLoader(
                nativeLoaderManager.loader, continueLoaderBuilder, 3)
            
            let handler = loader(nil, nil, nil)
            
            handler(task: .Cancel)
            
            XCTAssertEqual(4, nativeLoaderManager.loadingCount)
        }
        
        XCTAssertNil(weakNativeLoaderManager)
    }
    
    func testCallThreeTimesNativeLoaderOnError() {
        
        weak var weakNativeLoaderManager: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let nativeLoaderManager = JAsyncManager<Any>()
            weakNativeLoaderManager = nativeLoaderManager
            
            nativeLoaderManager.failAtLoadingError = JError(description: "test error")
            
            let continueLoaderBuilder = { (result: JResult<Any>) -> JAsyncTypes<Any>.JAsync? in
                
                switch result {
                case let .Value(v):
                    return nil
                default:
                    return nativeLoaderManager.loader
                }
            }
            
            let loader = repeatAsyncWithDelayLoader(nativeLoaderManager.loader, continueLoaderBuilder, 3)
            
            let handler = loader(nil, nil, nil)
            
            XCTAssertEqual(4, nativeLoaderManager.loadingCount)
        }
        
        XCTAssertNil(weakNativeLoaderManager)
    }
}
