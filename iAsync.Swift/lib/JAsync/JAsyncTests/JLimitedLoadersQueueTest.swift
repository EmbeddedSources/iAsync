//
//  JLimitedLoadersQueueTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class JLimitedLoadersQueueTest: XCTestCase {
    
    func testPerormTwoBlocksAndOneWaits() {
        
        weak var weakQueue: JLimitedLoadersQueue<JStrategyFifo<NSNull>>?
        
        var weakLoader1: JAsyncManager<NSNull>?
        var weakLoader2: JAsyncManager<NSNull>?
        var weakLoader3: JAsyncManager<NSNull>?
        var weakLoader4: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let queue = JLimitedLoadersQueue<JStrategyFifo<NSNull>>()
            queue.limitCount = 2
            
            weakQueue = queue
            
            let loader1 = JAsyncManager<NSNull>()
            let loader2 = JAsyncManager<NSNull>()
            let loader3 = JAsyncManager<NSNull>()
            let loader4 = JAsyncManager<NSNull>()
            
            var weakLoader1 = loader1
            var weakLoader2 = loader2
            var weakLoader3 = loader3
            var weakLoader4 = loader4
            
            let balancedLoader1 = queue.balancedLoaderWithLoader(loader1.loader)
            let balancedLoader2 = queue.balancedLoaderWithLoader(loader2.loader)
            let balancedLoader3 = queue.balancedLoaderWithLoader(loader3.loader)
            let balancedLoader4 = queue.balancedLoaderWithLoader(loader4.loader)
            
            //1. perform 4 blocks with limit - 2 (any finished)
            let cancel1 = balancedLoader1(nil, nil, nil)
            let cancel2 = balancedLoader2(nil, nil, nil)
            let cancelBalanced3 = balancedLoader3(nil, nil, nil)
            
            var resultError: NSError?
            let cancelBalanced4 = balancedLoader4(nil, nil, { (result: JResult<NSNull>) -> () in
                
                result.onError { resultError = $0 }
            })
            
            //2. Check that only first two runned
            XCTAssertEqual(loader1.loadingCount, 1)
            XCTAssertEqual(loader2.loadingCount, 1)
            XCTAssertEqual(loader3.loadingCount, 0)
            XCTAssertEqual(loader4.loadingCount, 0)
            
            //3. Finish first, check that 3-th was runned
            loader1.loaderFinishBlock!(result: JResult.value(NSNull()))
            XCTAssertTrue(loader1.finished)
            XCTAssertEqual(loader2.loadingCount, 1)
            XCTAssertEqual(loader3.loadingCount, 1)
            XCTAssertEqual(loader4.loadingCount, 0)
            
            //5. Cancel 4-th and than 3-th,
            // check that 3-th native was canceled
            // check that 4-th was not runned
            cancelBalanced4(task: .Cancel)
            cancelBalanced3(task: .Cancel)
            
            XCTAssertTrue(loader3.canceled)
            XCTAssertEqual(loader4.loadingCount, 0)
            
            //6. Finish second, and check that all loader was finished or canceled
            loader2.loaderFinishBlock!(result: JResult.value(NSNull()))
            XCTAssertTrue(loader1.finished)
            XCTAssertTrue(loader2.finished)
            XCTAssertTrue(loader3.canceled)
            XCTAssertTrue(resultError! is JAsyncFinishedByCancellationError)
        }
        
        XCTAssertNil(weakQueue)
        
        XCTAssertNil(weakLoader1)
        XCTAssertNil(weakLoader2)
        XCTAssertNil(weakLoader3)
        XCTAssertNil(weakLoader4)
    }
    
    func testOneOperationInQueue() {
        
        weak var weakQueue: JLimitedLoadersQueue<JStrategyFifo<NSNull>>?
        
        var weakLoader1: JAsyncManager<NSNull>?
        var weakLoader2: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let queue = JLimitedLoadersQueue<JStrategyFifo<NSNull>>()
            queue.limitCount = 1
            
            weakQueue = queue
            
            let loader1 = JAsyncManager<NSNull>()
            let loader2 = JAsyncManager<NSNull>()
            
            var weakLoader1 = loader1
            var weakLoader2 = loader2
            
            let balancedLoader1 = queue.balancedLoaderWithLoader(loader1.loader)
            let balancedLoader2 = queue.balancedLoaderWithLoader(loader2.loader)
            
            let cancel1 = balancedLoader1(nil, nil, nil)
            let cancel2 = balancedLoader2(nil, nil, nil)
            
            XCTAssertEqual(loader1.loadingCount, 1)
            XCTAssertEqual(loader2.loadingCount, 0)
            
            loader1.loaderFinishBlock!(result: JResult.value(NSNull()))
            
            XCTAssertTrue(loader1.finished)
            XCTAssertEqual(loader2.loadingCount, 1)
            
            loader2.loaderFinishBlock!(result: JResult.value(NSNull()))
        }
        
        XCTAssertNil(weakQueue)
        
        XCTAssertNil(weakLoader1)
        XCTAssertNil(weakLoader2)
    }
    
    func testBarrierLoader() {
        
        weak var weakQueue: JLimitedLoadersQueue<JStrategyFifo<NSNull>>?
        
        var weakLoader1: JAsyncManager<NSNull>?
        var weakLoader2: JAsyncManager<NSNull>?
        var weakLoader3: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let queue = JLimitedLoadersQueue<JStrategyFifo<NSNull>>()
            queue.limitCount = 3
            
            weakQueue = queue
            
            let loader1 = JAsyncManager<NSNull>()
            let loader2 = JAsyncManager<NSNull>()
            let loader3 = JAsyncManager<NSNull>()
            
            let balancedLoader1 = queue.balancedLoaderWithLoader(loader1.loader)
            let balancedLoader2 = queue.barrierBalancedLoaderWithLoader(loader2.loader)
            let balancedLoader3 = queue.balancedLoaderWithLoader(loader3.loader)
            
            //1. perform all blocks
            let cancel1 = balancedLoader1(nil, nil, nil)
            let cancel2 = balancedLoader2(nil, nil, nil)
            let cancel3 = balancedLoader3(nil, nil, nil)
            
            //2. Check that only first one runned
            XCTAssertEqual(loader1.loadingCount, 1)
            XCTAssertEqual(loader2.loadingCount, 0)
            XCTAssertEqual(loader3.loadingCount, 0)
            
            //3. Finish first, check that 2-th was runned
            loader1.loaderFinishBlock!(result: JResult.value(NSNull()))
            XCTAssertTrue(loader1.finished)
            XCTAssertEqual(loader2.loadingCount, 1)
            XCTAssertEqual(loader3.loadingCount, 0)
            
            //4. Finish second and check that 3-th was runned
            loader2.loaderFinishBlock!(result: JResult.value(NSNull()))
            XCTAssertTrue(loader2.finished)
            XCTAssertEqual(loader3.loadingCount, 1)
            
            loader3.loaderFinishBlock!(result: JResult.value(NSNull()))
            XCTAssertTrue(loader3.finished)
        }
        
        XCTAssertNil(weakQueue)
        
        XCTAssertNil(weakLoader1)
        XCTAssertNil(weakLoader2)
        XCTAssertNil(weakLoader3)
    }
    
    //TODO test when (active)native loader was canceled
    //TODO test usibscribe balanced
}
