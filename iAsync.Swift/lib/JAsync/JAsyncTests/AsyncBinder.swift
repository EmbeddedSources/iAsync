//
//  AsyncBinder.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 23.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class AsyncBinder: XCTestCase {
    
    func testNormalFinish() {
        
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let secondLoaderBlock = secondLoader.loader
            
            var blockResult: Int?
            
            let secondLoaderBinder = { (result: Int) -> JAsyncTypes<Int>.JAsync in
                
                blockResult = result
                return secondLoaderBlock
            }
            let asyncOp = bindSequenceOfAsyncs(firstLoader.loader, secondLoaderBinder)
            
            var finalResult: Int?
            
            let cancel = asyncOp(nil, nil, { (result: JResult<Int>) -> () in
                
                result.onValue { finalResult = $0 }
            })
            
            let firstResult = 1
            firstLoader.loaderFinishBlock!(result: JResult.value(firstResult))
            
            XCTAssertNotNil(blockResult)
            XCTAssertEqual(blockResult!, firstResult)
            XCTAssertFalse(secondLoader.finished)
            XCTAssertNil(finalResult)
            
            let secondResult = 2
            secondLoader.loaderFinishBlock!(result: JResult.value(secondResult))
            
            XCTAssertTrue(secondLoader.finished)
            XCTAssertNotNil(finalResult)
            XCTAssertEqual(finalResult!, secondResult)
        }
        
        XCTAssertNil(weakFirstLoader )
        XCTAssertNil(weakSecondLoader)
    }
    
    func testFailFirstLoader()
    {
        weak var weakFirstLoader : JAsyncManager<Int>?
        weak var weakSecondLoader: JAsyncManager<Int>?
        
        weak var testBlockFreed1: NSObject?
        weak var testBlockFreed2: NSObject?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Int>()
            let secondLoader = JAsyncManager<Int>()
            
            let secondLoaderBlock = secondLoader.loader
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let testBlockFreedTmp1: NSObject? = NSObject()
            testBlockFreed1 = testBlockFreedTmp1
            
            var finalError: NSError?
            var binderCalled = false
            
            let secondLoaderBinder = { (firstResult: Int) -> JAsyncTypes<Int>.JAsync in
                
                if testBlockFreedTmp1 != nil {
                    binderCalled = true
                }
                return secondLoaderBlock
            }
            let asyncOp = bindSequenceOfAsyncs(firstLoader.loader, secondLoaderBinder)
            
            let testBlockFreedTmp2: NSObject? = NSObject()
            testBlockFreed2 = testBlockFreedTmp2
            
            let cancel = asyncOp(nil, nil, { (result: JResult<Int>) -> () in
                
                if testBlockFreedTmp2 != nil {
                    result.onError { finalError = $0 }
                }
            })
            
            let failError = JError(description: "error1")
            firstLoader.loaderFinishBlock!(result: JResult.error(failError))
            
            XCTAssertFalse(binderCalled)
            XCTAssertNotNil(finalError)
            XCTAssertEqual(failError, finalError!)
        }
        
        XCTAssertNil(testBlockFreed1)
        XCTAssertNil(testBlockFreed2)
        
        XCTAssertNil(weakFirstLoader )
        XCTAssertNil(weakSecondLoader)
    }
}
