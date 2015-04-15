//
//  SequenceOfAsyncsTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 20.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class SequenceOfAsyncsTest: XCTestCase {
    
    //TODO current
    //TODO write full tests
    func testSequenceOfAsyncs() {
        
        weak var weakFirstLoader : JAsyncManager<NSObject>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        //if false {
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<NSObject>()
            let secondLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            weak var assignFirstLoader = firstLoader
            let loader2 = asyncWithDoneBlock(secondLoader.loader, { () -> () in
                
                XCTAssertTrue(assignFirstLoader!.finished, "First loader finished already")
            })
            
            let loader = sequenceOfAsyncs(firstLoader.loader, loader2)
            
            var sequenceResult: NSNull?
            var sequenceLoaderFinished = false
            
            let cancel = loader(nil, nil, { (result: JResult<NSNull>) -> () in
                
                result.onValue { value -> Void in
                    sequenceResult         = value
                    sequenceLoaderFinished = true
                }
            })
            
            XCTAssertFalse(firstLoader.finished  , "First loader not finished yet"   )
            XCTAssertFalse(secondLoader.finished , "Second loader not finished yet"  )
            XCTAssertFalse(sequenceLoaderFinished, "Sequence loader not finished yet")
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSObject()))
            
            XCTAssertTrue(firstLoader.finished   , "First loader finished already"   )
            XCTAssertFalse(secondLoader.finished , "Second loader not finished yet"  )
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
    
    func testCancelFirstLoaderOfSequence() {
        
        weak var weakFirstLoader : JAsyncManager<()>?
        weak var weakSecondLoader: JAsyncManager<()>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<()>()
            let secondLoader = JAsyncManager<()>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let cancel = loader(nil, nil, nil)
            
            XCTAssertFalse(firstLoader.canceled , "still not canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
            
            cancel(task: .Cancel)
            
            XCTAssertTrue(firstLoader.canceled, "canceled" )
            XCTAssertEqual(firstLoader.lastHandleFlag, .Cancel, "canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testCancelSecondLoaderOfSequence() {
        
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<NSNull>()
            let secondLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let cancel = loader(nil, nil, nil)
            
            XCTAssertFalse(firstLoader.canceled , "still not canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSNull()))
            
            XCTAssertFalse(firstLoader.canceled , "still not canceled")
            XCTAssertFalse(secondLoader.canceled, "still not canceled")
            
            cancel(task:.Cancel)
            
            XCTAssertFalse(firstLoader.canceled, "canceled")
            XCTAssertTrue(secondLoader.canceled, "still not canceled" )
            XCTAssertEqual(secondLoader.lastHandleFlag, .Cancel, "canceled")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testCancelSecondLoaderOfSequenceIfFirstInstantFinish() {
        
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader = JAsyncManager<NSNull>()
            firstLoader.finishAtLoadingResult = NSNull()
            
            let secondLoader = JAsyncManager<NSNull>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let cancel = loader(nil, nil, nil)
            
            XCTAssertTrue(firstLoader.finished  , "finished"    )
            XCTAssertFalse(secondLoader.finished, "not finished")
            
            cancel(task: .Cancel)
            
            XCTAssertFalse(firstLoader.canceled, "canceled")
            XCTAssertTrue(secondLoader.canceled, "still not canceled")
            XCTAssertEqual(secondLoader.lastHandleFlag, .Cancel, "canceled")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testFirstLoaderFailOfSequence() {
        
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSNull>?
        
        autoreleasepool {
            
            let firstLoader = JAsyncManager<NSNull>()
            firstLoader.failAtLoadingError = JError(description: "some test error")
            
            let secondLoader = JAsyncManager<NSNull>()
            secondLoader.finishAtLoadingResult = NSNull()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var sequenceLoaderFailed = false
            
            let cancel = loader(nil, nil, { (result: JResult<NSNull>) -> () in
                
                result.onError { sequenceLoaderFailed = true }
            })
            
            XCTAssertTrue(sequenceLoaderFailed  , "sequence failed")
            XCTAssertTrue(firstLoader.finished  , "first - finished")
            XCTAssertFalse(secondLoader.finished, "second - not finished")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testSequenceWithTwoLoader() {
        
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<NSObject>?
        
        autoreleasepool {
            let firstLoader  = JAsyncManager<NSNull>()
            let secondLoader = JAsyncManager<NSObject>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            var sequenceResult: NSObject? = nil
            let seconBlockResult = NSObject()
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var sequenceLoaderFinished = false
            
            let cancel = loader(nil, nil, { (result: JResult<NSObject>) -> () in
                
                result.onValue { value -> Void in
                    sequenceResult         = value
                    sequenceLoaderFinished = true
                }
            })
            
            XCTAssertFalse(sequenceLoaderFinished, "sequence not finished")
            XCTAssertFalse(firstLoader.finished  , "firstLoader not finished")
            XCTAssertFalse(secondLoader.finished , "firstLoader not finished")
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSNull()))
            
            XCTAssertFalse(sequenceLoaderFinished, "sequence not finished"    )
            XCTAssertTrue(firstLoader.finished   , "firstLoader not finished" )
            XCTAssertFalse(secondLoader.finished , "secondLoader not finished")
            
            secondLoader.loaderFinishBlock!(result: JResult.value(seconBlockResult))
            
            XCTAssertTrue(sequenceLoaderFinished, "sequence finished")
            XCTAssertTrue(firstLoader.finished  , "firstLoader finished")
            XCTAssertTrue(secondLoader.finished , "secondLoader finished")
            
            XCTAssertEqual(seconBlockResult, sequenceResult!, "secondLoader finished")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testCriticalErrorOnFailFirstLoaderWhenSequenceResultCallbackIsNil() {
        
        weak var weakFirstLoader : JAsyncManager<()>?
        weak var weakSecondLoader: JAsyncManager<()>?
        
        autoreleasepool {
            let firstLoader  = JAsyncManager<()>()
            let secondLoader = JAsyncManager<()>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            let cancel = loader(nil, nil, nil)
            
            firstLoader.loaderFinishBlock!(result: JResult.error(JError(description: "some error")))
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testImmediatelyCancelCallbackOfFirstLoader() {
        
        weak var weakFirstLoader : JAsyncManager<()>?
        weak var weakSecondLoader: JAsyncManager<()>?
        
        autoreleasepool {
            let firstLoader  = JAsyncManager<()>()
            let secondLoader = JAsyncManager<()>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            firstLoader.cancelAtLoading = .CancelWithYesFlag
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var progressCallbackCalled = false
            let progressCallback = { (progressInfo: AnyObject) -> () in
                
                progressCallbackCalled = true
            }
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<()>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
            
            XCTAssertFalse(progressCallbackCalled, "progressCallback mismatch")
            XCTAssertTrue(finishError! is JAsyncFinishedByCancellationError, "cancelCallback mismatch")
            
            XCTAssertEqual(0, secondLoader.loadingCount, "unwanted invocation - second loader")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testImmediatelyCancelCallbackOfSecondLoader()
    {
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<()>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<NSNull>()
            let secondLoader = JAsyncManager<()>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            secondLoader.cancelAtLoading = .CancelWithYesFlag
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var progressCallbackCalled = false
            let progressCallback = { (progressInfo: AnyObject) -> () in
                
                progressCallbackCalled = true
            }
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<()>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(progressCallback, nil, doneCallback)
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSNull()))
            
            XCTAssertFalse(progressCallbackCalled)
            XCTAssertTrue(finishError! is JAsyncFinishedByCancellationError)
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testUnsubscribeCallForFirstLoader()
    {
        weak var weakFirstLoader : JAsyncManager<()>?
        weak var weakSecondLoader: JAsyncManager<()>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<()>()
            let secondLoader = JAsyncManager<()>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<()>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(nil, nil, doneCallback)
            
            cancel(task: .UnSubscribe)
            
            XCTAssertTrue((finishError != nil && finishError! is JAsyncFinishedByUnsubscriptionError))
            XCTAssertEqual(0, secondLoader.loadingCount, "should not be called")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
    
    func testUnsubscribeCallForSecondLoader()
    {
        weak var weakFirstLoader : JAsyncManager<NSNull>?
        weak var weakSecondLoader: JAsyncManager<()>?
        
        autoreleasepool {
            
            let firstLoader  = JAsyncManager<NSNull>()
            let secondLoader = JAsyncManager<()>()
            
            weakFirstLoader  = firstLoader
            weakSecondLoader = secondLoader
            
            let loader = sequenceOfAsyncs(firstLoader.loader, secondLoader.loader)
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<()>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = loader(nil, nil, doneCallback)
            
            XCTAssertEqual(0, secondLoader.loadingCount, "should not be called")
            
            firstLoader.loaderFinishBlock!(result: JResult.value(NSNull()))
            cancel(task: .UnSubscribe)
            
            XCTAssertTrue((finishError != nil && finishError! is JAsyncFinishedByUnsubscriptionError))
            XCTAssertEqual(1, secondLoader.loadingCount, "should be called")
        }
        
        XCTAssertNil(weakFirstLoader , "object should be released")
        XCTAssertNil(weakSecondLoader, "object should be released")
    }
}
