//
//  JCachedAsync.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 12.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public enum CachedAsyncTypes<Value>
{
    public typealias JResultSetter = (value: Value) -> ()
    public typealias JResultGetter = () -> Value?
}

//TODO20 test immediately cancel
//TODO20 test cancel calback for each observer

public class JCachedAsync<Key: Hashable, Value> {
    
    public init() {}
    
    private var delegatesByKey = [Key:ObjectRelatedPropertyData<Value>]()
    
    //type PropertyExtractorType = PropertyExtractor[Key, Value]
    private typealias PropertyExtractorType = PropertyExtractor<Key, Value>
    
    //func clearDelegates(delegates: mutable.ArrayBuffer[CallbacksBlocksHolder[Value]]) {
    private func clearDelegates(delegates: [CallbacksBlocksHolder<Value>]) {
        
        for callbacks in delegates {
            callbacks.clearCallbacks()
        }
    }
    
    private func clearDataForPropertyExtractor(propertyExtractor: PropertyExtractorType) {
        
        if propertyExtractor.cacheObject == nil {
            return
        }
        propertyExtractor.clearDelegates()
        propertyExtractor.setLoaderHandler(nil)
        propertyExtractor.setAsyncLoader  (nil)
        propertyExtractor.clear()
    }
    
    private func cancelBlock(propertyExtractor: PropertyExtractorType, callbacks: CallbacksBlocksHolder<Value>) -> JAsyncHandler {
        
        return { (task: JAsyncHandlerTask) -> () in
            
            if propertyExtractor.cleared {
                return
            }
            
            let handlerOption = propertyExtractor.getLoaderHandler()
            
            if let handler = handlerOption {
                
                switch task {
                case .UnSubscribe:
                    let didLoadDataBlock = callbacks.finishCallback
                    propertyExtractor.removeDelegate(callbacks)
                    callbacks.clearCallbacks()
                    
                    didLoadDataBlock?(result: JResult.error(JAsyncFinishedByUnsubscriptionError()))
                case .Cancel:
                    handler(task: .Cancel)
                    self.clearDataForPropertyExtractor(propertyExtractor)//TODO should be already cleared here in finish callback
                case .Suspend, .Resume:
                    
                    propertyExtractor.eachDelegate({(callback: CallbacksBlocksHolder<Value>) -> () in
                        
                        if let onState = callback.stateCallback {
                            let state = task == .Resume
                                ?JAsyncState.Resumed
                                :JAsyncState.Suspended
                            onState(state: state)
                        }
                    })
                default:
                    fatalError("unsupported type")
                }
            }
        }
    }
    
    private func doneCallbackBlock(propertyExtractor: PropertyExtractorType) -> JAsyncTypes<Value>.JDidFinishAsyncCallback {
        
        return { (result: JResult<Value>) -> () in
            
            //TODO test this if
            //may happen when cancel
            if propertyExtractor.cacheObject == nil {
                return
            }
            
            result.onValue { value -> Void in
                propertyExtractor.setterOption?(value: value)
            }
            
            let copyDelegates = propertyExtractor.copyDelegates()
            
            self.clearDataForPropertyExtractor(propertyExtractor)
            
            for callbacks in copyDelegates {
                callbacks.finishCallback?(result: result)
                callbacks.clearCallbacks()
            }
        }
    }
    
    private func performNativeLoader(
        propertyExtractor: PropertyExtractorType,
        callbacks: CallbacksBlocksHolder<Value>) -> JAsyncHandler
    {
        func progressCallback(progressInfo: AnyObject) {
            
            propertyExtractor.eachDelegate({(delegate: CallbacksBlocksHolder<Value>) -> () in
                delegate.progressCallback?(progressInfo: progressInfo)
                return
            })
        }
        
        let doneCallback = doneCallbackBlock(propertyExtractor)
        
        func stateCallback(state: JAsyncState) {
            
            propertyExtractor.eachDelegate({(delegate: CallbacksBlocksHolder<Value>) -> () in
                delegate.stateCallback?(state: state)
                return
            })
        }
        
        let loader  = propertyExtractor.getAsyncLoader()
        let handler = loader!(
            progressCallback: progressCallback,
            stateCallback: stateCallback,
            finishCallback: doneCallback)
        
        if propertyExtractor.cacheObject == nil {
            return jStubHandlerAsyncBlock
        }
        
        propertyExtractor.setLoaderHandler(handler)
        
        return cancelBlock(propertyExtractor, callbacks: callbacks)
    }
    
    public func isLoadingDataForUniqueKey(uniqueKey: Key) -> Bool {
        
        let resultOption = delegatesByKey[uniqueKey]
        return resultOption != nil
    }
    
    public var hasLoadingData: Bool {
        
        return delegatesByKey.count != 0
    }
    
    public func asyncOpMerger(loader: JAsyncTypes<Value>.JAsync, uniqueKey: Key) -> JAsyncTypes<Value>.JAsync {
        
        return asyncOpWithPropertySetter(nil, getter: nil, uniqueKey: uniqueKey, loader: loader)
    }
    
    public func asyncOpWithPropertySetter(
        setter: CachedAsyncTypes<Value>.JResultSetter?,
        getter: CachedAsyncTypes<Value>.JResultGetter?,
        uniqueKey: Key,
        loader: JAsyncTypes<Value>.JAsync) -> JAsyncTypes<Value>.JAsync
    {
        return { (
            progressCallback: JAsyncProgressCallback?,
            stateCallback   : JAsyncChangeStateCallback?,
            finishCallback  : JAsyncTypes<Value>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            let propertyExtractor = PropertyExtractorType(setter     : setter,
                getter     : getter,
                cacheObject: self,
                uniqueKey  : uniqueKey,
                loader     : loader)
            
            if let result = propertyExtractor.getAsyncResult() {
                
                finishCallback?(result: JResult.value(result))
                
                propertyExtractor.clear()
                return jStubHandlerAsyncBlock
            }
            
            let callbacks = CallbacksBlocksHolder(progressCallback: progressCallback, stateCallback: stateCallback, finishCallback: finishCallback)
            
            let hasDelegates = propertyExtractor.hasDelegates()
            
            propertyExtractor.addDelegate(callbacks)
            
            return hasDelegates
                ?self.cancelBlock(propertyExtractor, callbacks: callbacks)
                :self.performNativeLoader(propertyExtractor, callbacks: callbacks)
        }
    }
}

private class ObjectRelatedPropertyData<T>
{
    //var delegates    : mutable.ArrayBuffer[CallbacksBlocksHolder[T]] = null
    var delegates = [CallbacksBlocksHolder<T>]()
    
    var loaderHandler: JAsyncHandler?
    //var asyncLoader  : Async[T] = null
    var asyncLoader  : JAsyncTypes<T>.JAsync?
    
    func copyDelegates() -> [CallbacksBlocksHolder<T>] {
        
        let result = delegates.map({ (callbacks: CallbacksBlocksHolder<T>) -> CallbacksBlocksHolder<T> in
            
            return CallbacksBlocksHolder(
                progressCallback: callbacks.progressCallback,
                stateCallback   : callbacks.stateCallback   ,
                finishCallback  : callbacks.finishCallback)
        })
        return result
    }
    
    func clearDelegates() {
        for callbacks in delegates {
            callbacks.clearCallbacks()
        }
        delegates.removeAll(keepCapacity: false)
    }
    
    func eachDelegate(block: (obj: CallbacksBlocksHolder<T>) -> ()) {
        for element in delegates {
            block(obj: element)
        }
    }
    
    func hasDelegates() -> Bool {
        return delegates.count > 0
    }
    
    //func getDelegates: mutable.ArrayBuffer[CallbacksBlocksHolder[ValueT]] = {
    func addDelegate(delegate: CallbacksBlocksHolder<T>) {
        delegates.append(delegate)
    }
    
    func removeDelegate(delegate: CallbacksBlocksHolder<T>) {
        for (index, callbacks) in enumerate(delegates) {
            if delegate === callbacks {
                delegates.removeAtIndex(index)
                break
            }
        }
    }
}

private class CallbacksBlocksHolder<T>
{
    var progressCallback: JAsyncProgressCallback?
    var stateCallback   : JAsyncChangeStateCallback?
    var finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?
    
    init(progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?)
    {
        self.progressCallback = progressCallback
        self.stateCallback    = stateCallback
        self.finishCallback   = finishCallback
    }
    
    func clearCallbacks() {
        
        progressCallback = nil
        stateCallback    = nil
        finishCallback   = nil
    }
}

private class PropertyExtractor<KeyT: Hashable, ValueT> {
    
    var cleared = false
    
    var setterOption: CachedAsyncTypes<ValueT>.JResultSetter?
    var getterOption: CachedAsyncTypes<ValueT>.JResultGetter?
    var cacheObject : JCachedAsync<KeyT, ValueT>?
    var uniqueKey   : KeyT
    
    init(
        setter     : CachedAsyncTypes<ValueT>.JResultSetter?,
        getter     : CachedAsyncTypes<ValueT>.JResultGetter?,
        cacheObject: JCachedAsync<KeyT, ValueT>,
        uniqueKey  : KeyT,
        loader     : JAsyncTypes<ValueT>.JAsync)
    {
        self.setterOption = setter
        self.getterOption = getter
        self.cacheObject  = cacheObject
        self.uniqueKey    = uniqueKey
        setAsyncLoader(loader)
    }
    
    //private def getObjectRelatedPropertyData: ObjectRelatedPropertyData[ValueT] = {
    func getObjectRelatedPropertyData() -> ObjectRelatedPropertyData<ValueT>
    {
        let resultOption = cacheObject!.delegatesByKey[uniqueKey]
        
        if let result = resultOption {
            return result
        }
        
        let result = ObjectRelatedPropertyData<ValueT>()
        cacheObject!.delegatesByKey[uniqueKey] = result
        return result
    }
    
    func copyDelegates() -> [CallbacksBlocksHolder<ValueT>] {
        return getObjectRelatedPropertyData().copyDelegates()
    }
    
    func eachDelegate(block: (obj: CallbacksBlocksHolder<ValueT>) -> ()) {
        return getObjectRelatedPropertyData().eachDelegate(block)
    }
    
    func hasDelegates() -> Bool {
        return getObjectRelatedPropertyData().hasDelegates()
    }
    
    func clearDelegates() {
        getObjectRelatedPropertyData().clearDelegates()
    }
    
    //func getDelegates: mutable.ArrayBuffer[CallbacksBlocksHolder[ValueT]] = {
    func addDelegate(delegate: CallbacksBlocksHolder<ValueT>) {
        getObjectRelatedPropertyData().addDelegate(delegate)
    }
    
    func removeDelegate(delegate: CallbacksBlocksHolder<ValueT>) {
        getObjectRelatedPropertyData().removeDelegate(delegate)
    }
    
    func getLoaderHandler() -> JAsyncHandler? {
        return getObjectRelatedPropertyData().loaderHandler
    }
    
    func setLoaderHandler(handler: JAsyncHandler?) {
        getObjectRelatedPropertyData().loaderHandler = handler
    }
    
    //def getAsyncLoader: Async[ValueT] =
    func getAsyncLoader() -> JAsyncTypes<ValueT>.JAsync? {
        return getObjectRelatedPropertyData().asyncLoader
    }
    
    //def setAsyncLoader(loader: Async[ValueT])
    func setAsyncLoader(loader: JAsyncTypes<ValueT>.JAsync?) {
        getObjectRelatedPropertyData().asyncLoader = loader
    }
    
    func getAsyncResult() -> ValueT? {
        return getterOption?()
    }
    
    func clear() {
        
        if cleared {
            return
        }
        
        cacheObject!.delegatesByKey.removeValueForKey(uniqueKey)
        
        setterOption = nil
        getterOption = nil
        cacheObject  = nil
        
        cleared = true
    }
}
