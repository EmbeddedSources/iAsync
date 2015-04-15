//
//  TrySequenceOfAsyncsTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 20.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class TrySequenceOfAsyncsTest: XCTestCase {
    
    //TODO write full tests
    func testTrySequenceOfAsyncs()
    {
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<NSNull>()
            let secondLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            weak var assignFirstLoader = firstLoader
            
            let loader2 = asyncWithDoneBlock(secondLoader.loader, {
                XCTAssertTrue(assignFirstLoader!.finished, "First loader finished already")
            })
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, loader2)
            
            var sequenceResult: NSNull?
            
            var sequenceLoaderFinished = false
            
            let cancel = loader(nil, nil, { (result: JResult<NSNull>) -> () in
                
                result.onValue { v -> Void in
                    sequenceResult = v.value
                    sequenceLoaderFinished = true
                }
            })
            
            XCTAssertFalse(firstLoader.finished, "First loader not finished yet")
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertFalse(sequenceLoaderFinished, "Sequence loader not finished yet")
            
            firstLoader.loaderFinishBlock!(result: JResult.error(JError(description: "some error")))
            
            XCTAssertTrue(firstLoader.finished, "First loader finished already")
            XCTAssertFalse(secondLoader.finished, "Second loader not finished yet")
            XCTAssertFalse(sequenceLoaderFinished, "Sequence loader finished already")
            
            let result = NSNull()
            secondLoader.loaderFinishBlock!(result: JResult.value(result))
            
            XCTAssertTrue(firstLoader.finished  , "First loader finished already"   )
            XCTAssertTrue(secondLoader.finished , "Second loader not finished yet"  )
            XCTAssertTrue(sequenceLoaderFinished, "Sequence loader finished already")
            
            XCTAssertEqual(result, sequenceResult!, "Sequence loader finished already")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testCancelFirstLoaderOfTrySequence()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Any>()
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let handler = loader(nil, nil, nil)
            
            XCTAssertFalse(firstLoader.canceled , "still not canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
            
            handler(task: .Cancel)
            
            XCTAssertTrue(firstLoader.canceled  , "canceled")
            XCTAssertTrue(firstLoader.lastHandleFlag == .Cancel, "canceled")
            XCTAssertFalse( secondLoader.canceled, "still not canceled" )
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testCancelSecondLoaderOfTrySequence()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Any>()
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let handler = loader(nil, nil, nil)
            
            XCTAssertFalse(firstLoader.canceled , "still not canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
            
            firstLoader.loaderFinishBlock!(result: JResult.error(JError(description: "some error")))
            
            XCTAssertFalse(firstLoader.canceled , "still not canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
            
            handler(task: .Cancel)
            
            XCTAssertFalse(firstLoader.canceled, "canceled")
            XCTAssertTrue(secondLoader.canceled, "still not canceled")
            XCTAssertEqual(secondLoader.lastHandleFlag, .Cancel, "canceled")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testCancelSecondLoaderOfTrySequenceIfFirstInstantFinish()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader = JAsyncManager<Any>()
            firstLoader.failAtLoadingError = JError(description: "some test error")
            
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let handler = loader(nil, nil, nil)
            
            XCTAssertTrue (firstLoader.finished , "finished"    )
            XCTAssertFalse(secondLoader.finished, "not finished")
            
            handler(task: .Cancel)
            
            XCTAssertFalse(firstLoader.canceled, "canceled")
            XCTAssertTrue(secondLoader.canceled, "still not canceled")
            XCTAssertEqual(secondLoader.lastHandleFlag, .Cancel, "canceled")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testFirstLoaderOkOfTrySequence()
    {
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader = JAsyncManager<NSNull>()
            firstLoader.finishAtLoadingResult = NSNull()
            
            let secondLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var sequenceLoaderFinished = false
            
            let cancel = loader(nil, nil, { (result: JResult<NSNull>) -> () in
                
                result.onValue { sequenceLoaderFinished = true }
            })
            
            XCTAssertTrue(sequenceLoaderFinished, "sequence failed"      )
            XCTAssertTrue(firstLoader.finished  , "first - finished"     )
            XCTAssertFalse(secondLoader.finished, "second - not finished")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testTrySequenceWithOneLoader()
    {
        weak var weakFirstLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader = firstLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader)
            
            var sequenceLoaderFinished = false
            
            let cancel = loader(nil, nil, { (result: JResult<NSNull>) -> () in
                
                result.onValue { sequenceLoaderFinished = true }
            })
            
            XCTAssertFalse(sequenceLoaderFinished, "sequence not finished")
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSNull()))
            
            XCTAssertTrue(sequenceLoaderFinished, "sequence finished")
        }
        
        XCTAssertNil(weakFirstLoader, "object should be released")
    }
    
    func testCriticalErrorOnFailFirstLoaderWhenTrySequenceResultCallbackIsNil()
    {
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<NSNull>()
            let secondLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let cancel = loader(nil, nil, nil)
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSNull()))
        }
        
        XCTAssertNil(weakFirstLoader )
        XCTAssertNil(weakSecondLoader)
    }
    
    func testImmediatelyCancelCallbackOfFirstLoader()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Any>()
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            firstLoader.cancelAtLoading = .CancelWithYesFlag
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var progressCallbackCalled = false
            let progressCallback = { (progressInfo: Any) -> () in
                
                progressCallbackCalled = true
            }
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<Any>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
            
            XCTAssertFalse(progressCallbackCalled)
            XCTAssertTrue(finishError != nil && finishError! is JAsyncFinishedByCancellationError)
            
            XCTAssertEqual(0, secondLoader.loadingCount)
        }
        
        XCTAssertNil(weakFirstLoader )
        XCTAssertNil(weakSecondLoader)
    }
    
    func testImmediatelyCancelCallbackOfSecondLoader()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Any>()
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            secondLoader.cancelAtLoading = .CancelWithYesFlag
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var progressCallbackCalled = false
            let progressCallback = { (progressInfo: Any) -> () in
                
                progressCallbackCalled = true
            }
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<Any>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
            
            firstLoader.loaderFinishBlock!(result: JResult.error(JError(description: "test")))
            
            XCTAssertFalse(progressCallbackCalled)
            XCTAssertTrue(finishError != nil && finishError! is JAsyncFinishedByCancellationError)
        }
        
        XCTAssertNil(weakFirstLoader )
        XCTAssertNil(weakSecondLoader)
    }
    
    func testUnsubscribeCallForFirstLoader()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Any>()
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var finishError: NSError?
            var finishBlockCallCount = 0
            
            let doneCallback = { (result: JResult<Any>) -> () in
                
                finishBlockCallCount += 1
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(nil, nil, doneCallback)
            
            cancel(task: .UnSubscribe)
            
            XCTAssertTrue((finishError != nil && finishError! is JAsyncFinishedByUnsubscriptionError))
            XCTAssertEqual(1,  firstLoader.loadingCount, "should not be called")
            XCTAssertEqual(0, secondLoader.loadingCount, "should not be called")
            
            XCTAssertEqual(1, finishBlockCallCount, "should be called only once")
            
            firstLoader.loaderFinishBlock!(result: JResult.value("sone result"))
            
            XCTAssertEqual(1,  firstLoader.loadingCount, "should not be called")
            XCTAssertEqual(0, secondLoader.loadingCount, "should not be called")
            
            XCTAssertEqual(1, finishBlockCallCount, "should be called only once")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testUnsubscribeCallForSecondLoader()
    {
        weak var weakFirstLoader : JAsyncManager<Any>?
        weak var weakSecondLoader: JAsyncManager<Any>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<Any>()
            let secondLoader = JAsyncManager<Any>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = trySequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<Any>) -> () in
                
                switch result {
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(nil, nil, doneCallback)
            
            XCTAssertEqual(0, secondLoader.loadingCount, "should not be called")
            
            firstLoader.loaderFinishBlock!(result: JResult.error(JError(description: "test")))
            cancel(task: .UnSubscribe)
            
            XCTAssertTrue((finishError != nil && finishError! is JAsyncFinishedByUnsubscriptionError))
            XCTAssertEqual(1, secondLoader.loadingCount, "should be called")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
}
