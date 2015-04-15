//
//  JAsyncHelpers.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public func asyncWithJResult<T>(result: JResult<T>) -> JAsyncTypes<T>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
        stateCallback: JAsyncChangeStateCallback?,
        doneCallback: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        doneCallback?(result: result)
        return jStubHandlerAsyncBlock
    }
}

public func asyncWithResult<T>(result: T) -> JAsyncTypes<T>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback: JAsyncChangeStateCallback?,
              doneCallback: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        doneCallback?(result: JResult.value(result))
        return jStubHandlerAsyncBlock
    }
}

public func asyncWithError<T>(error: NSError) -> JAsyncTypes<T>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              doneCallback    : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        doneCallback?(result: JResult.error(error))
        return jStubHandlerAsyncBlock
    }
}

public func asyncWithHandlerFlag<T>(task: JAsyncHandlerTask) -> JAsyncTypes<T>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback: JAsyncChangeStateCallback?,
              doneCallback: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        processHandlerFlag(task, stateCallback, doneCallback)
        return jStubHandlerAsyncBlock
    }
}

public func processHandlerFlag<T>(
    task         : JAsyncHandlerTask,
    stateCallback: JAsyncChangeStateCallback?,
    doneCallback : JAsyncTypes<T>.JDidFinishAsyncCallback?) {
        
    let errorOption = JAsyncAbstractFinishError.buildFinishError(task)
    
    if let error = errorOption {
        
        doneCallback?(result: JResult.error(error))
    } else {
        
        assert(task.rawValue <= JAsyncHandlerTask.Undefined.rawValue)
        
        stateCallback?(state: task == .Suspend
            ?JAsyncState.Suspended
            :JAsyncState.Resumed)
    }
}

func neverFinishAsync() -> JAsyncTypes<AnyObject>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              doneCallback    : JAsyncTypes<AnyObject>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        var wasCanceled = false
        
        return { (task: JAsyncHandlerTask) -> () in
            
            if wasCanceled {
                return
            }
            
            wasCanceled = (task == .Cancel
                || task == .UnSubscribe)
            
            processHandlerFlag(task, stateCallback, doneCallback)
        }
    }
}

public func asyncWithSyncOperationInCurrentQueue<T>(block: JAsyncTypes<T>.JSyncOperation) -> JAsyncTypes<T>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              doneCallback    : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        doneCallback?(result: block())
        return jStubHandlerAsyncBlock
    }
}

public func asyncWithFinishCallbackBlock<T>(
    loader: JAsyncTypes<T>.JAsync,
    finishCallbackBlock: JAsyncTypes<T>.JDidFinishAsyncCallback) -> JAsyncTypes<T>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              doneCallback    : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        return loader(
            progressCallback: progressCallback,
            stateCallback   : stateCallback,
            finishCallback  : { (result: JResult<T>) -> () in
                
            finishCallbackBlock(result: result)
            doneCallback?(result: result)
        })
    }
}

public func asyncWithFinishHookBlock<T, R>(loader: JAsyncTypes<T>.JAsync, finishCallbackHook: JAsyncTypes2<T, R>.JDidFinishAsyncHook) -> JAsyncTypes<R>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              finishCallback  : JAsyncTypes<R>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        return loader(
            progressCallback: progressCallback,
            stateCallback   : stateCallback   ,
            finishCallback: { (result: JResult<T>) -> () in
            
            finishCallbackHook(result: result, finishCallback: finishCallback)
        })
    }
}

func asyncWithStartAndFinishBlocks<T>(
    loader          : JAsyncTypes<T>.JAsync,
    startBlockOption: JSimpleBlock?,
    finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncTypes<T>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              doneCallback    : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        startBlockOption?()
        
        let wrappedDoneCallback = { (result: JResult<T>) -> () in
            
            finishCallback?(result: result)
            doneCallback?(result: result)
        }
        return loader(
            progressCallback: progressCallback,
            stateCallback   : stateCallback   ,
            finishCallback  : wrappedDoneCallback)
    }
}

func asyncWithOptionalStartAndFinishBlocks<T>(
    loader        : JAsyncTypes<T>.JAsync,
    startBlock    : JSimpleBlock?,
    finishCallback: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncTypes<T>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              doneCallbackOption: JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        var loading = true
        
        let wrappedDoneCallback = { (result: JResult<T>) -> () in
            
            loading = false
            
            finishCallback?(result: result)
            doneCallbackOption?(result: result)
        }
        
        let cancel = loader(
            progressCallback: progressCallback,
            stateCallback   : stateCallback   ,
            finishCallback  : wrappedDoneCallback)
        
        if loading {
            
            startBlock?()
            return cancel
        }
        
        return jStubHandlerAsyncBlock
    }
}

public func asyncWithAnalyzer<T, R>(
    data: T, analyzer: JUtilsBlockDefinitions2<T, R>.JAnalyzer) -> JAsyncTypes<R>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              finishCallback  : JAsyncTypes<R>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        finishCallback?(result: analyzer(object: data))
        return jStubHandlerAsyncBlock
    }
}

public func asyncBinderWithAnalyzer<T, R>(analyzer: JUtilsBlockDefinitions2<T, R>.JAnalyzer) -> JAsyncTypes2<T, R>.JAsyncBinder {
    
    return { (result: T) -> JAsyncTypes<R>.JAsync in
        return asyncWithAnalyzer(result, analyzer)
    }
}

public func asyncWithChangedResult<T, R>(
    loader: JAsyncTypes<T>.JAsync,
    resultBuilder: JUtilsBlockDefinitions2<T, R>.JMappingBlock) -> JAsyncTypes<R>.JAsync
{
    let secondLoaderBinder = asyncBinderWithAnalyzer({ (result: T) -> JResult<R> in
        
        let newResult = resultBuilder(object: result)
        return JResult.value(newResult)
    })
    
    return bindSequenceOfAsyncs(loader, secondLoaderBinder)
}

func asyncWithChangedProgress<T>(
    loader: JAsyncTypes<T>.JAsync,
    resultBuilder: JUtilsBlockDefinitions2<AnyObject, AnyObject>.JMappingBlock) -> JAsyncTypes<T>.JAsync
{
    return { (progressCallback: JAsyncProgressCallback?,
              stateCallback   : JAsyncChangeStateCallback?,
              finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let progressCallbackWrapper = { (info: AnyObject) -> () in
            
            progressCallback?(progressInfo: resultBuilder(object: info))
            return
        }
        
        return loader(
            progressCallback: progressCallbackWrapper,
            stateCallback   : stateCallback          ,
            finishCallback  : finishCallback)
    }
}

func loaderWithAdditionalParalelLoaders<R, T>(
    original: JAsyncTypes<R>.JAsync,
    additionalLoaders: JAsyncTypes<T>.JAsync...) -> JAsyncTypes<R>.JAsync
{
    let groupLoader = groupOfAsyncsArray(additionalLoaders)
    let allLoaders  = groupOfAsyncs(original, groupLoader)
    
    let getResult = { (result: (R, [T])) -> JAsyncTypes<R>.JAsync in
        
        return asyncWithResult(result.0)
    }
    
    return bindSequenceOfAsyncs(allLoaders, getResult)
}

public func logErrorForLoader<T>(loader: JAsyncTypes<T>.JAsync) -> JAsyncTypes<T>.JAsync
{
    return { (
        progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let wrappedDoneCallback = { (result: JResult<T>) -> () in
            
            result.onError { $0.writeErrorWithJLogger() }
            finishCallback?(result: result)
        }
        
        let cancel = loader(
            progressCallback: progressCallback,
            stateCallback: stateCallback,
            finishCallback: wrappedDoneCallback)
        
        return cancel
    }
}

public func ignoreProgressLoader<T>(loader: JAsyncTypes<T>.JAsync) -> JAsyncTypes<T>.JAsync
{
    return { (
        progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        return loader(
            progressCallback: progressCallback,
            stateCallback: stateCallback,
            finishCallback: finishCallback)
    }
}
