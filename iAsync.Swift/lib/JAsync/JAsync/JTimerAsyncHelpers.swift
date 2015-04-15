//
//  JTimerAsyncHelpers.swift
//  JTimer
//
//  Created by Vladimir Gorbenko on 27.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

//TODO remove inheritence from NSObject
public class JAsyncTimerResult : NSObject {}

//TODO remove inheritence from NSObject
private class JAsyncScheduler : NSObject, JAsyncInterface {
    
    typealias ResultType = JAsyncTimerResult
    
    private var _timer: JTimer?
    
    private let duration: NSTimeInterval
    private let leeway  : NSTimeInterval
    private let callbacksQueue: dispatch_queue_t
    
    init(duration: NSTimeInterval,
        leeway  : NSTimeInterval,
        callbacksQueue: dispatch_queue_t) {
            
            self.duration = duration
            self.leeway   = leeway
            self.callbacksQueue = callbacksQueue
    }
    
    private var _finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    
    func asyncWithResultCallback(
        finishCallback  : JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback   : JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback) {
            
            _finishCallback   = finishCallback
            
            startIfNeeds()
    }
    
    func doTask(task: JAsyncHandlerTask) {
        
        switch (task) {
            
        case .UnSubscribe, .Cancel, .Suspend:
            _timer = nil
        case .Resume:
            startIfNeeds()
        default:
            assert(false)
        }
    }
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
    
    private func startIfNeeds() {
        
        if _timer != nil {
            return
        }
        
        let timer = JTimer()
        _timer = timer
        let cancel = timer.addBlock( { [weak self] (cancel: JCancelScheduledBlock) in
            
            cancel()
            self?._finishCallback?(result: JResult.value(JAsyncTimerResult()))
        }, duration:duration, leeway:leeway, dispatchQueue:callbacksQueue)
    }
}

public func asyncWithDelay(delay: NSTimeInterval, leeway: NSTimeInterval) -> JAsyncTypes<JAsyncTimerResult>.JAsync {
    
    assert(NSThread.isMainThread(), "main thread expected")
    return asyncWithDelayWithDispatchQueue(delay, leeway, dispatch_get_main_queue())
}

func asyncWithDelayWithDispatchQueue(
    delay         : NSTimeInterval,
    leeway        : NSTimeInterval,
    callbacksQueue: dispatch_queue_t) -> JAsyncTypes<JAsyncTimerResult>.JAsync
{
    let factory = { () -> JAsyncScheduler in
        
        let asyncObject = JAsyncScheduler(duration: delay, leeway: leeway, callbacksQueue: callbacksQueue)
        return asyncObject
    }
    return JAsyncBuilder.buildWithAdapterFactoryWithDispatchQueue(factory, callbacksQueue: callbacksQueue)
}

public func asyncAfterDelay<T>(
    delay : NSTimeInterval,
    leeway: NSTimeInterval,
    loader: JAsyncTypes<T>.JAsync) -> JAsyncTypes<T>.JAsync
{
    assert(NSThread.isMainThread())
    return asyncAfterDelayWithDispatchQueue(
        delay,
        leeway,
        loader,
        dispatch_get_main_queue())
}

func asyncAfterDelayWithDispatchQueue<T>(
    delay : NSTimeInterval,
    leeway: NSTimeInterval,
    loader: JAsyncTypes<T>.JAsync,
    callbacksQueue: dispatch_queue_t) -> JAsyncTypes<T>.JAsync
{
    let timerLoader = asyncWithDelayWithDispatchQueue(delay, leeway, callbacksQueue)
    let delayedLoader = bindSequenceOfAsyncs(timerLoader, { (result: JAsyncTimerResult) -> JAsyncTypes<JAsyncTimerResult>.JAsync in
        return asyncWithResult(result)
    })
    
    return sequenceOfAsyncs(delayedLoader, loader)
}

enum JRepeatAsyncTypes<T> {
    
    typealias JContinueLoaderWithResult = (result: JResult<T>) -> JAsyncTypes<T>.JAsync?
}

public func repeatAsyncWithDelayLoader<T>(
    nativeLoader: JAsyncTypes<T>.JAsync,
    continueLoaderBuilder: JRepeatAsyncTypes<T>.JContinueLoaderWithResult,
    maxRepeatCount: Int/*remove redundent parameter*/) -> JAsyncTypes<T>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        var currentLoaderHandlerHolder: JAsyncHandler?
        
        var progressCallbackHolder = progressCallback
        var stateCallbackHolder    = stateCallback
        var finishCallbackHolder   = finishCallback
        
        let progressCallbackWrapper = { (progressInfo: AnyObject) -> () in
            
            progressCallbackHolder?(progressInfo: progressInfo)
            return
        }
        let stateCallbackWrapper = { (state: JAsyncState) -> () in
            
            stateCallbackHolder?(state: state)
            return
        }
        let doneCallbackkWrapper = { (result: JResult<T>) -> () in
            
            if let finishCallback = finishCallbackHolder {
                finishCallbackHolder = nil
                finishCallback(result: result)
            }
        }
        
        var currentLeftCount = maxRepeatCount
        
        let clearCallbacks = { () -> () in
            progressCallbackHolder = nil
            stateCallbackHolder    = nil
            finishCallbackHolder   = nil
        }
        
        var finishHookHolder: JAsyncTypes2<T, T>.JDidFinishAsyncHook?
        
        let finishCallbackHook = { (result: JResult<T>, _: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> () in
            
            let finish = { () -> () in
                
                finishHookHolder = nil
                doneCallbackkWrapper(result)
                
                clearCallbacks()
            }
            
            switch result {
            case let .Error(error):
                if error is JAsyncFinishedByCancellationError {
                    finish()
                    return
                }
            default:
                break
            }
            
            var newLoader = continueLoaderBuilder(result: result)
            
            if newLoader == nil || currentLeftCount == 0 {
                
                finish()
            } else {
                
                currentLeftCount = currentLeftCount > 0
                    ?currentLeftCount - 1
                    :currentLeftCount
                
                let loader = asyncWithFinishHookBlock(newLoader!, finishHookHolder!)
                
                currentLoaderHandlerHolder = loader(
                    progressCallback: progressCallbackWrapper,
                    stateCallback: stateCallbackWrapper,
                    finishCallback: doneCallbackkWrapper)
            }
        }
        
        finishHookHolder = finishCallbackHook
        
        let loader = asyncWithFinishHookBlock(nativeLoader, finishCallbackHook)
        
        currentLoaderHandlerHolder = loader(
            progressCallback: progressCallback,
            stateCallback   : stateCallbackWrapper,
            finishCallback  : doneCallbackkWrapper)
        
        return { (task: JAsyncHandlerTask) -> () in
            
            if task == .Cancel {
                finishHookHolder = nil
            }
            
            if let handler = currentLoaderHandlerHolder {
                
                if task == .UnSubscribe {
                    
                    clearCallbacks()
                } else {
                    
                    handler(task: task)
                    
                    if task == .Cancel {
                        currentLoaderHandlerHolder = nil
                    }
                }
            }
        }
    }
}

public func repeatAsync<T>(
    nativeLoader: JAsyncTypes<T>.JAsync,
    continueLoaderBuilder: JRepeatAsyncTypes<T>.JContinueLoaderWithResult,
    delay : NSTimeInterval,
    leeway: NSTimeInterval,
    maxRepeatCount: Int) -> JAsyncTypes<T>.JAsync
{
    let continueLoaderBuilderWrapper = { (result: JResult<T>) -> JAsyncTypes<T>.JAsync? in
        
        let loaderOption = continueLoaderBuilder(result: result)
        
        if let loader = loaderOption {
            let timerLoader = asyncWithDelay(delay, leeway)
            let delayedLoader = bindSequenceOfAsyncs(timerLoader, { (result: JAsyncTimerResult) -> JAsyncTypes<JAsyncTimerResult>.JAsync in
                return asyncWithResult(result)
            })
            
            return sequenceOfAsyncs(delayedLoader, loader)
        }
        
        return nil
    }
    
    return repeatAsyncWithDelayLoader(nativeLoader, continueLoaderBuilderWrapper, maxRepeatCount)
}
