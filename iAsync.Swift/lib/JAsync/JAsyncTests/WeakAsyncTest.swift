//
//  WeakAsyncTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 19.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

class WeakAsyncTest: XCTestCase {
    
    func testCancelActionAfterUnsubscribeOnDealloc() {
        
        var cancelCallbackCalled = false
        var cancel: JAsyncHandler?
        
        autoreleasepool {
            let obj = JAsyncsOwner(task: .UnSubscribe)
            
            var operation = { (
                progressCallback: JAsyncProgressCallback?,
                stateCallback   : JAsyncChangeStateCallback?,
                finishCallback  : JAsyncTypes<()>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                
                return { (task: JAsyncHandlerTask) -> () in
                    processHandlerFlag(task, stateCallback, finishCallback)
                }
            }
            
            operation = obj.ownedAsync(operation)
            
            cancel = operation(nil, nil, {(result: JResult<()>) -> () in
                
                result.onError { cancelCallbackCalled = $0 is JAsyncFinishedByUnsubscriptionError }
            })
        }
        
        XCTAssertTrue(cancelCallbackCalled, "Cancel callback should be called")
        cancelCallbackCalled = false
        
        cancel!(task: .Cancel)
        
        XCTAssertFalse(cancelCallbackCalled, "Cancel callback should not be called after dealloc")
    }
    
    func testOnceCancelBlockCallingOnDealloc()
    {
        var cancelCallbackCallCount = 0
        
        autoreleasepool {
            
            let obj = JAsyncsOwner(task: .UnSubscribe)
            
            var operation = { (progressCallback: JAsyncProgressCallback?,
                stateCallback: JAsyncChangeStateCallback?,
                finishCallback: JAsyncTypes<()>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                
                return { (task: JAsyncHandlerTask) -> () in
                    ++cancelCallbackCallCount
                    processHandlerFlag(task, stateCallback, finishCallback)
                }
            }
            
            operation = obj.ownedAsync(operation)
            
            let cancel = operation(nil, nil, nil)
        }
        
        XCTAssertEqual(1, cancelCallbackCallCount, "Cancel callback should not be called after dealloc")
    }
    
    func testCancelCallbackCallingOnCancelBlock() {
        
        let obj = JAsyncsOwner(task: .UnSubscribe)
        
        var cancelBlockCalled = false
        
        var operation = { (
            progressCallback: JAsyncProgressCallback?,
            stateCallback: JAsyncChangeStateCallback?,
            finishCallback: JAsyncTypes<()>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            return { (task: JAsyncHandlerTask) -> () in
                
                cancelBlockCalled = (task == .Cancel)
                processHandlerFlag(task, stateCallback, finishCallback)
            }
        }
        
        operation = obj.ownedAsync(operation)
        
        var cancelCallbackCalled = false
        
        let cancel = operation(nil, nil, {(result: JResult<()>) -> () in
            
            result.onError { cancelCallbackCalled = $0 is JAsyncFinishedByCancellationError }
        })
        
        cancel(task: .Cancel)
        
        XCTAssertTrue(cancelCallbackCalled, "Cancel callback should not be called after dealloc")
        XCTAssertTrue(cancelBlockCalled, "Cancel callback should not be called after dealloc")
    }
    
    // When unsubscribe from autoCancelAsync -> native should not be canceled
    func testUnsubscribeFromAutoCancel() {
        
        let operationOwner = JAsyncsOwner(task: .Cancel)
        
        var nativeCancelBlockCalled = false
        
        var operation = { (
            progressCallback: JAsyncProgressCallback?,
            stateCallback: JAsyncChangeStateCallback?,
            finishCallback: JAsyncTypes<()>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            return { (task: JAsyncHandlerTask) -> () in
                
                nativeCancelBlockCalled = (task == .UnSubscribe)
                processHandlerFlag(task, stateCallback, finishCallback)
            }
        }
        
        let autoCancelOperation = operationOwner.ownedAsync(operation)
        
        var deallocated = false
        var cancel: JAsyncHandler?
        var cancelCallbackCalled = false
        
        weak var weakOwnedByCallbacks: JAsyncsOwner?
        
        autoreleasepool {
            
            autoreleasepool {
                let ownedByCallbacks: JAsyncsOwner! = JAsyncsOwner(task: .Cancel)
                weakOwnedByCallbacks = ownedByCallbacks
            
                let progressCallback = { (progressInfo: AnyObject) -> () in
                    //simulate using object in callback block
                    if ownedByCallbacks != nil {
                        { ()-> () in }()
                    }
                }
                let doneCallback = {(result: JResult<()>) -> () in
                
                    result.onError { error -> Void in
                        //simulate using object in callback block
                        if ownedByCallbacks != nil {
                            cancelCallbackCalled = error is JAsyncFinishedByUnsubscriptionError
                        }
                    }
                }
            
                cancel = autoCancelOperation(progressCallback, nil, doneCallback)
            }
        
            XCTAssertFalse(weakOwnedByCallbacks == nil, "owned_by_callbacks_ object should not be deallocated")
        
            cancel!(task: .UnSubscribe)
        }
        
        XCTAssertTrue(nativeCancelBlockCalled    , "Native cancel block should not be called")
        XCTAssertTrue(weakOwnedByCallbacks == nil, "owned_by_callbacks_ objet should be deallocated")
        XCTAssertTrue(cancelCallbackCalled       , "cancel callback should ba called")
    }
    
    func testCancelCallbackCallingForNativeLoaderWhenWeekDelegateRemove() {
        
        weak var weakOperationOwner: JAsyncsOwner?
        
        autoreleasepool {
            let operationOwner: JAsyncsOwner! = JAsyncsOwner(task: .Cancel)
            weakOperationOwner = operationOwner
            
            var unsibscribeCancelBlockCalled = false
            var nativeCancelBlockCalled      = false
            weak var weakDelegate: JAsyncsOwner?
            
            autoreleasepool {
                let delegate = JAsyncsOwner(task: .UnSubscribe)
                weakDelegate = delegate
                
                var operation: JAsyncTypes<()>.JAsync?
                
                autoreleasepool {
                    var operation = { (
                        progressCallback: JAsyncProgressCallback?,
                        stateCallback: JAsyncChangeStateCallback?,
                        finishCallback: JAsyncTypes<()>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                        
                        return { (task: JAsyncHandlerTask) -> () in
                            
                            nativeCancelBlockCalled = (task == .UnSubscribe)
                            processHandlerFlag(task, stateCallback, finishCallback)
                        }
                    }
                    //like native operation still living
                    
                    let autoCancelOperation = operationOwner!.ownedAsync(operation)
                    
                    let doneCallback = { (result: JResult<()>) -> () in
                        
                        if operationOwner != nil {
                            result.onError { error -> unsibscribeCancelBlockCalled = $0 is JAsyncFinishedByUnsubscriptionError }
                        }
                    }
                    let loader = delegate.ownedAsync(autoCancelOperation)
                    let cancel = loader(nil, nil, doneCallback)
                }
            }
            
            XCTAssertTrue(weakDelegate == nil         )
            XCTAssertTrue(nativeCancelBlockCalled     )
            XCTAssertTrue(unsibscribeCancelBlockCalled)
        }
        XCTAssertTrue(weakOperationOwner == nil)
    }
}
