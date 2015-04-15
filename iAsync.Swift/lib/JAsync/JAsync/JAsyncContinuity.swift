//
//  JAsyncContinuity.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 12.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

private var waterfallFirstObjectInstance: JWaterwallFirstObject? = nil

private class JWaterwallFirstObject {
    
    class func sharedWaterwallFirstObject() -> JWaterwallFirstObject {
        
        if let instance = waterfallFirstObjectInstance {
            return instance
        }
        let instance = JWaterwallFirstObject()
        waterfallFirstObjectInstance = instance
        return instance
    }
}

//calls loaders while success
public func sequenceOfAsyncs<T, R>(
    loader1: JAsyncTypes<T>.JAsync,
    loader2: JAsyncTypes<R>.JAsync) -> JAsyncTypes<R>.JAsync {
    
    let binder1 = { (result: JWaterwallFirstObject) -> JAsyncTypes<T>.JAsync in
        return loader1
    }
    let binder2 = { (result: T) -> JAsyncTypes<R>.JAsync in
        return loader2
    }
    let binder = bindSequenceOfBindersPair(binder1, binder2)
    return binder(JWaterwallFirstObject.sharedWaterwallFirstObject())
}

public func sequenceOfAsyncs<T1, T2, R>(
    loader1: JAsyncTypes<T1>.JAsync,
    loader2: JAsyncTypes<T2>.JAsync,
    loader3: JAsyncTypes<R>.JAsync) -> JAsyncTypes<R>.JAsync
{
    return sequenceOfAsyncs(
        sequenceOfAsyncs(loader1, loader2),
        loader3)
}

public func sequenceOfAsyncs<T1, T2, T3, R>(
    loader1: JAsyncTypes<T1>.JAsync,
    loader2: JAsyncTypes<T2>.JAsync,
    loader3: JAsyncTypes<T3>.JAsync,
    loader4: JAsyncTypes<R>.JAsync) -> JAsyncTypes<R>.JAsync
{
    return sequenceOfAsyncs(
        sequenceOfAsyncs(loader1, loader2, loader3),
        loader4)
}

func sequenceOfAsyncsArray<T>(loaders: [JAsyncTypes<T>.JAsync]) -> JAsyncTypes<T>.JAsync {

    var firstBlock = { (result: JWaterwallFirstObject) -> JAsyncTypes<T>.JAsync in
        return loaders[0]
    }
    
    for index in 1..<(loaders.count) {
        
        let secondBlockBinder = { (result: T) -> JAsyncTypes<T>.JAsync in
            return loaders[index]
        }
        firstBlock = bindSequenceOfBindersPair(firstBlock, secondBlockBinder)
    }
    
    return firstBlock(JWaterwallFirstObject.sharedWaterwallFirstObject())
}

private func bindSequenceOfBindersPair<P1, R1, R2>(
    firstBinder : JAsyncTypes2<P1, R1>.JAsyncBinder,
    secondBinder: JAsyncTypes2<R1, R2>.JAsyncBinder) -> JAsyncTypes2<P1, R2>.JAsyncBinder {
    
    return { (bindResult: P1) -> JAsyncTypes<R2>.JAsync in
        
        return { (
            progressCallback: JAsyncProgressCallback?,
            stateCallback   : JAsyncChangeStateCallback?,
            finishCallback  : JAsyncTypes<R2>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            var handlerBlockHolder: JAsyncHandler?
            
            var progressCallbackHolder = progressCallback
            var stateCallbackHolder    = stateCallback
            var finishCallbackHolder   = finishCallback
            
            let progressCallbackWrapper = { (progressInfo: AnyObject) -> () in
                
                progressCallbackHolder?(progressInfo: progressInfo)
            }
            let stateCallbackWrapper = { (state: JAsyncState) -> () in
                
                stateCallbackHolder?(state: state)
            }
            let doneCallbackWrapper = { (result: JResult<R2>) -> () in
                
                if let callback = finishCallbackHolder {
                    
                    finishCallbackHolder = nil
                    callback(result: result)
                }
                
                progressCallbackHolder = nil
                stateCallbackHolder    = nil
                handlerBlockHolder     = nil
            }
            
            var finished = false
            
            let fistLoaderDoneCallback = { (result: JResult<R1>) -> () in
                
                switch result {
                case let .Value(v):
                    let secondLoader = secondBinder(v.value)
                    handlerBlockHolder = secondLoader(
                        progressCallback: progressCallbackWrapper,
                        stateCallback   : stateCallbackWrapper,
                        finishCallback  : doneCallbackWrapper)
                case let .Error(error):
                    finished = true
                    doneCallbackWrapper(JResult.error(error))
                }
            }
            
            let firstLoader = firstBinder(bindResult)
            let firstCancel = firstLoader(
                progressCallback: progressCallbackWrapper,
                stateCallback: stateCallbackWrapper,
                finishCallback: fistLoaderDoneCallback)
            
            if finished {
                return jStubHandlerAsyncBlock
            }
            
            if handlerBlockHolder == nil {
                handlerBlockHolder = firstCancel
            }
            
            return { (task: JAsyncHandlerTask) -> () in
                
                if let currentHandler = handlerBlockHolder {
                    
                    if task == .Cancel || task == .UnSubscribe {
                            
                        handlerBlockHolder = nil
                    }
                    
                    if task == .UnSubscribe {
                        finishCallbackHolder?(result: JResult.error(JAsyncFinishedByUnsubscriptionError()))
                    } else {
                        currentHandler(task: task)
                    }
                    
                    if task == .Cancel || task == .UnSubscribe {
                            
                        progressCallbackHolder = nil
                        stateCallbackHolder    = nil
                        finishCallbackHolder   = nil
                    }
                }
            }
        }
    }
}

public func bindSequenceOfAsyncs<R1, R2>(
    firstLoader: JAsyncTypes<R1>.JAsync,
    firstBinder: JAsyncTypes2<R1, R2>.JAsyncBinder) -> JAsyncTypes<R2>.JAsync
{
    var firstBlock = { (result: JWaterwallFirstObject) -> JAsyncTypes<R1>.JAsync in
        return firstLoader
    }
    
    let binder = bindSequenceOfBindersPair(firstBlock, firstBinder)
    
    return binder(JWaterwallFirstObject.sharedWaterwallFirstObject())
}

public func bindSequenceOfAsyncs<R1, R2, R3>(
    firstLoader : JAsyncTypes<R1>.JAsync,
    firstBinder : JAsyncTypes2<R1, R2>.JAsyncBinder,
    secondBinder: JAsyncTypes2<R2, R3>.JAsyncBinder) -> JAsyncTypes<R3>.JAsync
{
    let loader = bindSequenceOfAsyncs(
        bindSequenceOfAsyncs(firstLoader, firstBinder),
        secondBinder)
    return loader
}

public func bindSequenceOfAsyncs<R1, R2, R3, R4>(
    firstLoader : JAsyncTypes<R1>.JAsync,
    binder1: JAsyncTypes2<R1, R2>.JAsyncBinder,
    binder2: JAsyncTypes2<R2, R3>.JAsyncBinder,
    binder3: JAsyncTypes2<R3, R4>.JAsyncBinder) -> JAsyncTypes<R4>.JAsync
{
    let loader = bindSequenceOfAsyncs(
        bindSequenceOfAsyncs(firstLoader, binder1, binder2), binder3)
    return loader
}

public func bindSequenceOfAsyncs<R1, R2, R3, R4, R5>(
    firstLoader : JAsyncTypes<R1>.JAsync,
    binder1: JAsyncTypes2<R1, R2>.JAsyncBinder,
    binder2: JAsyncTypes2<R2, R3>.JAsyncBinder,
    binder3: JAsyncTypes2<R3, R4>.JAsyncBinder,
    binder4: JAsyncTypes2<R4, R5>.JAsyncBinder) -> JAsyncTypes<R5>.JAsync
{
    let loader = bindSequenceOfAsyncs(
        bindSequenceOfAsyncs(firstLoader, binder1, binder2, binder3), binder4)
    return loader
}

/////////////////////////////// SEQUENCE WITH BINDING ///////////////////////////////

//calls binders while success
public func binderAsSequenceOfBinders<T>(binders: JAsyncTypes2<T, T>.JAsyncBinder...) -> JAsyncTypes2<T, T>.JAsyncBinder {
    
    var firstBinder = binders[0]
    
    if binders.count < 2 {
        return firstBinder
    }
    
    for index in 1..<(binders.count) {
        
        firstBinder = bindSequenceOfBindersPair(firstBinder, binders[index])
    }
    
    return firstBinder
}

/////////////////////////////////// TRY SEQUENCE ///////////////////////////////////

//calls loaders untill success
public func trySequenceOfAsyncs<T: Any>(firstLoader: JAsyncTypes<T>.JAsync, nextLoaders: JAsyncTypes<T>.JAsync...) -> JAsyncTypes<T>.JAsync
{
    var allLoaders = [firstLoader]
    allLoaders += nextLoaders
    
    return trySequenceOfAsyncsArray(allLoaders)
}

public func trySequenceOfAsyncsArray<T>(loaders: [JAsyncTypes<T>.JAsync]) -> JAsyncTypes<T>.JAsync {
    
    assert(loaders.count > 0)
    
    var firstBlock = { (result: JWaterwallFirstObject) -> JAsyncTypes<T>.JAsync in
        return loaders[0]
    }
    
    for index in 1..<(loaders.count) {
        
        let secondBlockBinder = { (result: NSError) -> JAsyncTypes<T>.JAsync in
            return loaders[index]
        }
        firstBlock = bindTrySequenceOfBindersPair(firstBlock, secondBlockBinder)
    }
    
    return firstBlock(JWaterwallFirstObject.sharedWaterwallFirstObject())
}

private func bindTrySequenceOfBindersPair<T, R>(firstBinder: JAsyncTypes2<T, R>.JAsyncBinder,
                                               secondBinder: JAsyncTypes2<NSError, R>.JAsyncBinder?) -> JAsyncTypes2<T, R>.JAsyncBinder
{
    if let secondBinder = secondBinder {
        
        return { (binderResult: T) -> JAsyncTypes<R>.JAsync in
            
            let firstLoader = firstBinder(binderResult)
            
            return { (progressCallback: JAsyncProgressCallback?,
                      stateCallback: JAsyncChangeStateCallback?,
                      finishCallback: JAsyncTypes<R>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                
                var handlerBlockHolder: JAsyncHandler?
                
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
                let doneCallbackWrapper = { (result: JResult<R>) -> () in
                    
                    if let finish = finishCallbackHolder {
                        finishCallbackHolder = nil
                        finish(result: result)
                    }
                    
                    progressCallbackHolder = nil
                    stateCallbackHolder    = nil
                    handlerBlockHolder     = nil
                }
                
                let firstHandler = firstLoader(
                    progressCallback: progressCallbackWrapper,
                    stateCallback: stateCallbackWrapper,
                    finishCallback: { (result: JResult<R>) -> () in
                        
                        switch result {
                        case let .Value(v):
                            doneCallbackWrapper(JResult.value(v.value))
                        case let .Error(error):
                            if error is JAsyncFinishedByCancellationError {
                                
                                doneCallbackWrapper(JResult.error(error))
                                return
                            }
                            
                            let secondLoader = secondBinder(error)
                            handlerBlockHolder = secondLoader(
                                progressCallback: progressCallbackWrapper,
                                stateCallback: stateCallbackWrapper,
                                finishCallback: doneCallbackWrapper)
                        }
                })
                
                if handlerBlockHolder == nil {
                    handlerBlockHolder = firstHandler
                }
                
                return { (task: JAsyncHandlerTask) -> () in
                    
                    if handlerBlockHolder == nil {
                        return
                    }
                    
                    let currentHandler = handlerBlockHolder
                    
                    if task.rawValue <= JAsyncHandlerTask.Cancel.rawValue {
                        handlerBlockHolder = nil
                    }
                    
                    if task == .UnSubscribe {
                        finishCallbackHolder?(result: JResult.error(JAsyncFinishedByUnsubscriptionError()))
                    } else {
                        currentHandler!(task: task)
                    }
                    
                    if task.rawValue <= JAsyncHandlerTask.Cancel.rawValue {
                        
                        progressCallbackHolder = nil
                        stateCallbackHolder    = nil
                        finishCallbackHolder   = nil
                    }
                }
            }
        }
    }
    
    return firstBinder
}

/////////////////////////////// TRY SEQUENCE WITH BINDING ///////////////////////////////

//calls loaders while success
//@@ next binder will receive an error if previous operation fails
public func bindTrySequenceOfAsyncs<R>(firstLoader: JAsyncTypes<R>.JAsync, nextBinders: JAsyncTypes2<NSError, R>.JAsyncBinder...) -> JAsyncTypes<R>.JAsync {
    
    var firstBlock = { (data: JWaterwallFirstObject) -> JAsyncTypes<R>.JAsync in
        return firstLoader
    }
    
    for nextBinder in nextBinders {
        
        firstBlock = bindTrySequenceOfBindersPair(firstBlock, nextBinder)
    }
    
    return firstBlock(JWaterwallFirstObject.sharedWaterwallFirstObject())
}

/////////////////////////////////////// GROUP //////////////////////////////////////

//calls finish callback when all loaders finished
public func groupOfAsyncs<R1, R2>(firstLoaer: JAsyncTypes<R1>.JAsync, secondLoaer: JAsyncTypes<R2>.JAsync) -> JAsyncTypes<(R1, R2)>.JAsync {
    
    return groupOfAsyncsPair(firstLoaer, secondLoaer)
}

public func groupOfAsyncsArray<R>(loaders: [JAsyncTypes<R>.JAsync]) -> JAsyncTypes<[R]>.JAsync {
    
    if loaders.count == 0 {
        return asyncWithResult([])
    }
    
    func resultToArrayForLoader(async: JAsyncTypes<R>.JAsync) -> JAsyncTypes<[R]>.JAsync {
        
        return bindSequenceOfAsyncs(async, { (value: R) -> JAsyncTypes<[R]>.JAsync in
            
            return asyncWithResult([value])
        })
    }
    
    func pairToArrayForLoader(async: JAsyncTypes<([R], R)>.JAsync) -> JAsyncTypes<[R]>.JAsync {
        
        return bindSequenceOfAsyncs(async, { (value: ([R], R)) -> JAsyncTypes<[R]>.JAsync in
            
            return asyncWithResult(value.0 + [value.1])
        })
    }
    
    let firstBlock = loaders[0]
    var arrayFirstBlock = resultToArrayForLoader(firstBlock)
    
    for index in 1..<(loaders.count) {
        
        let loader = groupOfAsyncs(arrayFirstBlock, loaders[index])
        arrayFirstBlock = pairToArrayForLoader(loader)
    }
    
    return arrayFirstBlock
}

private class ResultHandlerData<R1, R2> {
    
    var finished = false
    var loaded   = false
    
    var completeResult1: R1? = nil
    var completeResult2: R2? = nil
    
    var handlerHolder1: JAsyncHandler?
    var handlerHolder2: JAsyncHandler?
    
    var progressCallbackHolder: JAsyncProgressCallback?
    var stateCallbackHolder   : JAsyncChangeStateCallback?
    var finishCallbackHolder  : JAsyncTypes<(R1, R2)>.JDidFinishAsyncCallback?
    
    init(progressCallback: JAsyncProgressCallback?,
         stateCallback: JAsyncChangeStateCallback?,
         finishCallback: JAsyncTypes<(R1, R2)>.JDidFinishAsyncCallback?)
    {
        progressCallbackHolder = progressCallback
        stateCallbackHolder    = stateCallback
        finishCallbackHolder   = finishCallback
    }
}

private func makeResultHandler<RT, R1, R2>(
    index: Int,
    resultSetter: (v: RT, fields: ResultHandlerData<R1, R2>) -> (),
    fields: ResultHandlerData<R1, R2>
    ) -> JAsyncTypes<RT>.JDidFinishAsyncCallback
{
    return { (result: JResult<RT>) -> () in
        
        if fields.finished {
            return
        }
    
        if index == 0 {
            fields.handlerHolder1 = nil
        } else {
            fields.handlerHolder2 = nil
        }
        
        switch result {
        case let .Value(v):
            
            resultSetter(v: v.value, fields: fields)
            
            if fields.loaded {
                
                fields.finished = true
                
                fields.handlerHolder1 = nil
                fields.handlerHolder2 = nil
                
                fields.progressCallbackHolder = nil
                fields.stateCallbackHolder    = nil
                
                if let finish = fields.finishCallbackHolder {
                    fields.finishCallbackHolder   = nil
                    let completeResult = (fields.completeResult1!, fields.completeResult2!)
                    finish(result: JResult.value(completeResult))
                }
            } else {
                
                fields.loaded = true
            }
        case let .Error(error):
            fields.finished = true
            
            fields.progressCallbackHolder = nil
            fields.stateCallbackHolder    = nil
            
            if let finish = fields.finishCallbackHolder {
                fields.finishCallbackHolder = nil
                finish(result: JResult.error(error))
            }
        }
    }
}

private func groupOfAsyncsPair<R1, R2>(firstLoader: JAsyncTypes<R1>.JAsync, secondLoader: JAsyncTypes<R2>.JAsync) -> JAsyncTypes<(R1, R2)>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback: JAsyncChangeStateCallback?,
              finishCallback: JAsyncTypes<(R1, R2)>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let fields = ResultHandlerData(
            progressCallback: progressCallback,
            stateCallback   : stateCallback,
            finishCallback  : finishCallback)
        
        let progressCallbackWrapper = { (progressInfo: AnyObject) -> () in
            fields.progressCallbackHolder?(progressInfo: progressInfo)
            return
        }
        
        let stateCallbackWrapper = { (state: JAsyncState) -> () in
            stateCallback?(state: state)
            return
        }
            
        func setter1(val: R1, fields: ResultHandlerData<R1, R2>) {
            fields.completeResult1 = val
        }
        
        let firstLoaderResultHandler = makeResultHandler(0, setter1, fields)
        let loaderHandler1 = firstLoader(
            progressCallback: progressCallbackWrapper,
            stateCallback: stateCallbackWrapper,
            finishCallback: firstLoaderResultHandler)
        
        if fields.finished {
            
            let cancel = secondLoader(progressCallback: nil, stateCallback: nil, finishCallback: nil)
            return jStubHandlerAsyncBlock
        }
        
        fields.handlerHolder1 = loaderHandler1
        
        func setter2(val: R2, fields: ResultHandlerData<R1, R2>) {
            fields.completeResult2 = val
        }

        let secondLoaderResultHandler = makeResultHandler(1, setter2, fields)
        let loaderHandler2 = secondLoader(
            progressCallback: progressCallback,
            stateCallback: stateCallback,
            finishCallback: secondLoaderResultHandler)
        
        if fields.finished {
            
            return jStubHandlerAsyncBlock
        }
        
        fields.handlerHolder2 = loaderHandler2
        
        return { (task: JAsyncHandlerTask) -> () in
            
            let cancelOrUnSubscribe = task.rawValue <= JAsyncHandlerTask.Cancel.rawValue
            
            if let handler = fields.handlerHolder1 {
                
                if cancelOrUnSubscribe {
                    fields.handlerHolder1 = nil
                }
                handler(task: task)
            }
            
            if let handler = fields.handlerHolder2 {
                
                if cancelOrUnSubscribe {
                    fields.handlerHolder2 = nil
                }
                handler(task: task)
            }
            
            if cancelOrUnSubscribe {
                
                fields.progressCallbackHolder = nil
                fields.stateCallbackHolder    = nil
                fields.finishCallbackHolder   = nil
            }
        }
    }
}

///////////////////////// ADD OBSERVERS OF ASYNC OP. RESULT ////////////////////////

//doneCallbackHook called an cancel or finish loader's callbacks
public func asyncWithDoneBlock<T>(loader: JAsyncTypes<T>.JAsync, doneCallbackHook: JSimpleBlock?) -> JAsyncTypes<T>.JAsync {
    
    if let doneCallbackHook = doneCallbackHook {
        
        return { (
            progressCallback: JAsyncProgressCallback?,
            stateCallback: JAsyncChangeStateCallback?,
            finishCallback: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            let wrappedDoneCallback = { (result: JResult<T>) -> () in
                
                doneCallbackHook()
                finishCallback?(result: result)
            }
            return loader(
                progressCallback: progressCallback,
                stateCallback: stateCallback,
                finishCallback: wrappedDoneCallback)
        }
    }
    
    return loader
}
