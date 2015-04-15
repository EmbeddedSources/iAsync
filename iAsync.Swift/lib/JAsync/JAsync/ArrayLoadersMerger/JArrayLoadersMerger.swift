//
//  ArrayLoadersMerger.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JArrayLoadersMerger<Arg: Hashable, Res> {
    
    private typealias JAsyncOpAr = JAsyncTypes<[Res]>.JAsync
    
    public typealias JArrayOfObjectsLoader = (keys: [Arg]) -> JAsyncOpAr
    
    private var _pendingLoadersCallbacksByKey = [Arg:JLoadersCallbacksData<Res>]()
    private let _cachedAsyncOp = JCachedAsync<Arg, Res>()
    
    private let _arrayLoader: JArrayOfObjectsLoader
    
    private var activeArrayLoaders = [ActiveArrayLoader<Arg, Res>]()
    
    private func removeActiveLoader(loader: ActiveArrayLoader<Arg, Res>) {
        
        for (index, element) in enumerate(activeArrayLoaders) {
            
            if element === loader {
                self.activeArrayLoaders.removeAtIndex(index)
            }
        }
    }
    
    public init(arrayLoader: JArrayOfObjectsLoader) {
        _arrayLoader = arrayLoader
    }
    
    public func oneObjectLoader(key: Arg) -> JAsyncTypes<Res>.JAsync {
        
        let loader = { (progressCallback: JAsyncProgressCallback?,
                        stateCallback   : JAsyncChangeStateCallback?,
                        finishCallback  : JAsyncTypes<Res>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            if let currentLoader = self.activeLoaderForKey(key) {
                
                let resultIndex = currentLoader.indexOfKey(key)
                
                let loader = bindSequenceOfAsyncs(currentLoader.nativeLoader!, { (result: [Res]) -> JAsyncTypes<Res>.JAsync in
                    //TODO check length of result
                    return asyncWithResult(result[resultIndex])
                })
                
                return loader(
                    progressCallback: progressCallback,
                    stateCallback: stateCallback,
                    finishCallback: finishCallback)
            }
            
            let callbacks = JLoadersCallbacksData(
                progressCallback: progressCallback,
                stateCallback   : stateCallback,
                doneCallback    : finishCallback)
            
            self._pendingLoadersCallbacksByKey[key] = callbacks
            
            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> () in
                self?.runLoadingOfPendingKeys()
                return ()
            })
            
            return { (task: JAsyncHandlerTask) -> () in
                
                switch task {
                case .UnSubscribe:
                    let indexOption = self._pendingLoadersCallbacksByKey.indexForKey(key)
                    if let index = indexOption {
                        let (_, callbacks) = self._pendingLoadersCallbacksByKey[index]
                        self._pendingLoadersCallbacksByKey.removeAtIndex(index)
                        if let finishCallback = callbacks.doneCallback {
                            callbacks.doneCallback = nil
                            finishCallback(result: JResult.error(JAsyncFinishedByUnsubscriptionError()))
                        }
                        callbacks.unsubscribe()
                    } else {
                        self.activeLoaderForKey(key)?.unsubscribe(key)
                    }
                case .Cancel:
                    let indexOption = self._pendingLoadersCallbacksByKey.indexForKey(key)
                    if let index = indexOption {
                        let (_, callbacks) = self._pendingLoadersCallbacksByKey[index]
                        self._pendingLoadersCallbacksByKey.removeAtIndex(index)
                        if let finishCallback = callbacks.doneCallback {
                            callbacks.doneCallback = nil
                            finishCallback(result: JResult.error(JAsyncFinishedByCancellationError()))
                        }
                        callbacks.unsubscribe()
                    } else {
                        self.activeLoaderForKey(key)?.cancelLoader()
                    }
                case .Resume:
                    assert(false, "unsupported parameter: JFFAsyncHandlerTaskResume")
                case .Suspend:
                    assert(false, "unsupported parameter: JFFAsyncHandlerTaskSuspend")
                default:
                    assert(false, "invalid parameter")
                }
            }
        }
        
        return self._cachedAsyncOp.asyncOpWithPropertySetter(nil, getter: nil, uniqueKey: key, loader: loader)
    }
    
    private func runLoadingOfPendingKeys() {
        
        if _pendingLoadersCallbacksByKey.count == 0 {
            return
        }
        
        let loader = ActiveArrayLoader(loadersCallbacksByKey:_pendingLoadersCallbacksByKey, owner: self)
        
        activeArrayLoaders.append(loader)
        
        _pendingLoadersCallbacksByKey.removeAll(keepCapacity: true)
        
        loader.runLoader()
    }
    
    private func activeLoaderForKey(key: Arg) -> ActiveArrayLoader<Arg, Res>? {
        
        let result: ActiveArrayLoader<Arg, Res>? = firstMatch(activeArrayLoaders) { (activeLoader: ActiveArrayLoader<Arg, Res>) -> Bool in
            return activeLoader.loadersCallbacksByKey[key] != nil
        }
        return result
    }
}

private class JLoadersCallbacksData<Res> {
    
    var progressCallback: JAsyncProgressCallback?
    var stateCallback   : JAsyncChangeStateCallback?
    var doneCallback    : JAsyncTypes<Res>.JDidFinishAsyncCallback?
    
    var suspended = false
    
    init(progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        doneCallback    : JAsyncTypes<Res>.JDidFinishAsyncCallback?)
    {
        self.progressCallback = progressCallback
        self.stateCallback    = stateCallback
        self.doneCallback     = doneCallback
    }
    
    func unsubscribe() {
        progressCallback = nil
        stateCallback    = nil
        doneCallback     = nil
    }
    
    func copy() -> JLoadersCallbacksData {
        return JLoadersCallbacksData(
            progressCallback: self.progressCallback,
            stateCallback   : self.stateCallback   ,
            doneCallback    : self.doneCallback    )
    }
}

private class ActiveArrayLoader<Arg: Hashable, Res> {
    
    var loadersCallbacksByKey: [Arg:JLoadersCallbacksData<Res>]
    weak var owner: JArrayLoadersMerger<Arg, Res>?
    var keys = KeysType()
    
    private func indexOfKey(key: Arg) -> Int {
        
        for (index, currentKey) in enumerate(keys) {
            if currentKey == key {
                return index
            }
        }
        return -1
    }
    
    var nativeLoader : JAsyncTypes<[Res]>.JAsync? //Should be strong
    
    //TODO private
    var _nativeHandler: JAsyncHandler?
    
    init(loadersCallbacksByKey: [Arg:JLoadersCallbacksData<Res>], owner: JArrayLoadersMerger<Arg, Res>) {
        self.loadersCallbacksByKey = loadersCallbacksByKey
        self.owner                 = owner
    }
    
    func cancelLoader() {
        
        if let block = _nativeHandler {
            
            _nativeHandler = nil
            block(task: .Cancel)
            self.clearState()
        }
    }
    
    func clearState() {
        for (_, value) in loadersCallbacksByKey {
            value.unsubscribe()
        }
        loadersCallbacksByKey.removeAll(keepCapacity: false)
        owner?.removeActiveLoader(self)
        _nativeHandler = nil
        nativeLoader   = nil
    }
    
    func unsubscribe(key: Arg) {
        let indexOption = loadersCallbacksByKey.indexForKey(key)
        if let index = indexOption {
            
            let callbacks = loadersCallbacksByKey[index]
            callbacks.1.unsubscribe()
            loadersCallbacksByKey.removeAtIndex(index)
        }
    }
    
    typealias KeysType = HashableArray<Arg>
    let _cachedAsyncOp = JCachedAsync<KeysType,[Res]>()
    
    func runLoader() {
        
        assert(self.nativeLoader == nil)
        
        keys.removeAll()
        for (key, _) in loadersCallbacksByKey {
            keys.append(key)
        }
        
        let arrayLoader = owner!._arrayLoader(keys: Array(keys))
        
        let loader = { [weak self] (
            progressCallback: JAsyncProgressCallback?,
            stateCallback   : JAsyncChangeStateCallback?,
            finishCallback  : JAsyncTypes<[Res]>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            let progressCallbackWrapper = { (progressInfo: AnyObject) -> () in
                
                if let self_ = self {
                    
                    for (_, value) in self_.loadersCallbacksByKey {
                        value.progressCallback?(progressInfo: progressInfo)
                    }
                }
                
                progressCallback?(progressInfo: progressInfo)
            }
            
            let stateCallbackWrapper = { (state: JAsyncState) -> () in
                
                if let self_ = self {
                    
                    for (_, value) in self_.loadersCallbacksByKey {
                        value.stateCallback?(state: state)
                    }
                }
                
                stateCallback?(state: state)
            }
            
            let doneCallbackWrapper = { (result: JResult<[Res]>) -> () in
                
                let (results, error) = { () -> ([Res]?, NSError?) in
                    
                    switch result {
                    case let .Value(v):
                        return (v.value, nil)
                    case let .Error(locError):
                        return (nil, locError)
                    }
                }()
                
                if let self_ = self {
                    
                    var loadersCallbacksByKey = [Arg:JLoadersCallbacksData<Res>]()
                    for (key, value) in self_.loadersCallbacksByKey {
                        loadersCallbacksByKey[key] = value.copy()
                    }
                    self_.clearState()
                    
                    for (key, value) in loadersCallbacksByKey {
                        
                        //TODO test not full results array
                        let result : Res? = results != nil
                            ?results![self_.indexOfKey(key)]
                            :nil
                        
                        if let result = result {
                            
                            value.doneCallback?(result: JResult.value(result))
                        } else {
                            
                            value.doneCallback?(result: JResult.error(error!))
                        }
                        
                        value.unsubscribe()
                    }
                }
                
                if let results = results {
                    
                    finishCallback?(result: JResult.value(results))
                } else {
                    
                    finishCallback?(result: JResult.error(error!))
                }
            }
            
            return arrayLoader(
                progressCallback: progressCallbackWrapper,
                stateCallback: stateCallbackWrapper,
                finishCallback: doneCallbackWrapper)
        }
        
        let setter: CachedAsyncTypes<[Res]>.JResultSetter? = nil
        let getter: CachedAsyncTypes<[Res]>.JResultGetter? = nil
        
        let nativeLoader: JAsyncTypes<[Res]>.JAsync = _cachedAsyncOp.asyncOpWithPropertySetter(
            setter,
            getter: getter,
            uniqueKey: keys,
            loader: loader)
        
        self.nativeLoader = nativeLoader
        
        var finished = false
        let handler = nativeLoader(
            progressCallback: nil,
            stateCallback: nil,
            finishCallback: { (result: JResult<[Res]>) -> () in finished = true })
        
        if !finished {
            _nativeHandler = handler
        }
    }
}
