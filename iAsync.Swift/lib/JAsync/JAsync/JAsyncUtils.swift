//
//  JAsyncUtils.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 27.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

private let defaultQueueName = "com.jff.async_operations_library.general_queue"

//TODO remove this class
private class JBlockOperation<T> {
    
    //TODO make atomic
    private var finishedOrCanceled = false
    
    init(
        queueName         : String?,
        loadDataBlock     : JAsyncTypes<T>.JSyncOperationWithProgress,
        didLoadDataBlock  : JAsyncTypes<T>.JDidFinishAsyncCallback?,
        progressBlock     : JAsyncProgressCallback?,
        barrier           : Bool,
        currentQueue      : dispatch_queue_t = dispatch_get_main_queue(),
        serialOrConcurrent: dispatch_queue_attr_t = DISPATCH_QUEUE_CONCURRENT) {
        
        //TODO use cStringUsingEncoding(NSUTF8StringEncoding) instead
        let queue: dispatch_queue_t = { () -> dispatch_queue_t in
            
            if let queueName = queueName {
                return dispatch_queue_get_or_create(queueName, serialOrConcurrent)
            }
            
            return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        }()
        
        performBackgroundOperationInQueue(
            queue,
            barrier         : barrier,
            currentQueue    : currentQueue,
            loadDataBlock   : loadDataBlock,
            didLoadDataBlock: didLoadDataBlock,
            progressBlock   : progressBlock)
    }
    
    func cancel()  {
        
        if finishedOrCanceled {
            return
        }
        
        finishedOrCanceled = true
    }
    
    //TODO make private
    func performBackgroundOperationInQueue(
        queue           : dispatch_queue_t,
        barrier         : Bool,
        currentQueue    : dispatch_queue_t,
        loadDataBlock   : JAsyncTypes<T>.JSyncOperationWithProgress,
        didLoadDataBlock: JAsyncTypes<T>.JDidFinishAsyncCallback?,
        progressBlock   : JAsyncProgressCallback?) {
        
        let dispatchAsyncMethod = barrier
            ?{(dispatch_queue_t queue, dispatch_block_t block) -> () in dispatch_barrier_async(queue, block) }
            :{(dispatch_queue_t queue, dispatch_block_t block) -> () in dispatch_async(queue, block) }
        
        dispatchAsyncMethod(queue, { () -> () in
            
            if self.finishedOrCanceled {
                return
            }
            
            let progressCallback = { (info: AnyObject) -> () in
                //TODO to garante that finish will called after progress
                dispatch_async(currentQueue, { () -> () in
                    
                    if self.finishedOrCanceled {
                        return
                    }
                    progressBlock?(progressInfo: info)
                    return
                })
            }
            
            let result = loadDataBlock(progressCallback: progressCallback)
            
            dispatch_async(currentQueue, {
                
                if self.finishedOrCanceled {
                    return
                }
                
                self.finishedOrCanceled = true
                
                didLoadDataBlock?(result: result)
            })
        })
    }
}

//TODO !!! remove NSObjet inheritence
private class JAsyncAdapter<T> : NSObject, JAsyncInterface {
    
    let loadDataBlock  : JAsyncTypes<T>.JSyncOperationWithProgress
    let queueName      : String?
    let barrier        : Bool
    let currentQueue   : dispatch_queue_t
    let queueAttributes: dispatch_queue_attr_t
    
    init(loadDataBlock  : JAsyncTypes<T>.JSyncOperationWithProgress,
         queueName      : String?,
         barrier        : Bool,
         currentQueue   : dispatch_queue_t,
         queueAttributes: dispatch_queue_attr_t) {
        
        self.loadDataBlock   = loadDataBlock
        self.queueName       = queueName
        self.barrier         = barrier
        self.currentQueue    = currentQueue
        self.queueAttributes = queueAttributes
    }
    
    var operation: JBlockOperation<T>? = nil
    
    func asyncWithResultCallback(
        finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback,
        stateCallback   : JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback) {
            
        operation = JBlockOperation(
            queueName         : queueName,
            loadDataBlock     : loadDataBlock,
            didLoadDataBlock  : finishCallback,
            progressBlock     : progressCallback,
            barrier           : barrier,
            currentQueue      : currentQueue,
            serialOrConcurrent: queueAttributes)
    }
    
    func doTask(task: JAsyncHandlerTask) {
        
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
        if task == .Cancel {
            operation?.cancel()
            operation = nil
        }
    }
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
}

private func asyncWithSyncOperationWithProgressBlockAndQueue<T>(
    progressLoadDataBlock: JAsyncTypes<T>.JSyncOperationWithProgress,
    queueName: String,
    barrier: Bool,
    currentQueue: dispatch_queue_t,
    queueAttributes: dispatch_queue_attr_t) -> JAsyncTypes<T>.JAsync {
    
    let factory = { () -> JAsyncAdapter<T> in
        
        let asyncObject = JAsyncAdapter(
            loadDataBlock  : progressLoadDataBlock,
            queueName      : queueName,
            barrier        : barrier,
            currentQueue   : currentQueue,
            queueAttributes: queueAttributes)
        
        return asyncObject
    }
    return JAsyncBuilder.buildWithAdapterFactoryWithDispatchQueue(factory, callbacksQueue: currentQueue)
}

private func generalAsyncWithSyncOperationAndQueue<T>(
    loadDataBlock: JAsyncTypes<T>.JSyncOperation,
    queueName: String,
    barrier: Bool,
    currentQueue: dispatch_queue_t,
    attr: dispatch_queue_attr_t) -> JAsyncTypes<T>.JAsync
{
    let progressLoadDataBlock = { (progressCallback: JAsyncProgressCallback?) -> JResult<T> in
        
        return loadDataBlock()
    }
    
    return asyncWithSyncOperationWithProgressBlockAndQueue(
        progressLoadDataBlock,
        queueName,
        barrier,
        currentQueue,
        attr)
}

public func asyncWithSyncOperation<T>(loadDataBlock: JAsyncTypes<T>.JSyncOperation) -> JAsyncTypes<T>.JAsync {
    
    return asyncWithSyncOperationAndQueue(loadDataBlock, defaultQueueName)
}

public func asyncWithSyncOperationAndQueue<T>(loadDataBlock: JAsyncTypes<T>.JSyncOperation, queueName: String) -> JAsyncTypes<T>.JAsync {
    
    assert(NSThread.isMainThread())
    return generalAsyncWithSyncOperationAndQueue(
        loadDataBlock,
        queueName,
        false,
        dispatch_get_main_queue(),
        DISPATCH_QUEUE_CONCURRENT)
}

func asyncWithSyncOperationAndConfigurableQueue<T>(loadDataBlock: JAsyncTypes<T>.JSyncOperation, queueName: String, isSerialQueue: Bool) -> JAsyncTypes<T>.JAsync {
    
    assert(NSThread.isMainThread())
    let attr: dispatch_queue_attr_t = isSerialQueue
        ?0/*DISPATCH_QUEUE_SERIAL*/
        :DISPATCH_QUEUE_CONCURRENT
    
    return generalAsyncWithSyncOperationAndQueue(
        loadDataBlock,
        queueName,
        false,
        dispatch_get_main_queue(),
        attr)
}

func barrierAsyncWithSyncOperationAndQueue<T>(loadDataBlock: JAsyncTypes<T>.JSyncOperation, queueName: String) -> JAsyncTypes<T>.JAsync {
    
    assert(NSThread.isMainThread())
    return generalAsyncWithSyncOperationAndQueue(
        loadDataBlock,
        queueName,
        true,
        dispatch_get_main_queue(),
        DISPATCH_QUEUE_CONCURRENT)
}

public func asyncWithSyncOperationWithProgressBlock<T>(progressLoadDataBlock: JAsyncTypes<T>.JSyncOperationWithProgress) -> JAsyncTypes<T>.JAsync {
    
    assert(NSThread.isMainThread())
    return asyncWithSyncOperationWithProgressBlockAndQueue(
        progressLoadDataBlock,
        defaultQueueName,
        false,
        dispatch_get_main_queue(),
        DISPATCH_QUEUE_CONCURRENT)
}
