//
//  CachedAsyncsTest.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 23.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import XCTest

import JAsync
import JUtils

private class ObjectHolder<T> {
    
    let object: T
    init(object: T) {
        self.object = object
    }
}

private class TestClassWithProperties<ValueType> {
    
    var dict = [String:ValueType]()
    
    let cacher       = JCachedAsync<String, ValueType>()
    let loadersOwner = JAsyncsOwner(task: .UnSubscribe)
}

class CachedAsyncsTest: XCTestCase {
    
    func testImmediatelyResult()
    {
        weak var weakNativeLoader: JAsyncManager<Int>?
        weak var weakCacher: JCachedAsync<String, Int>?
        
        autoreleasepool {
            
            let nativeLoader = JAsyncManager<Int>()
            
            nativeLoader.finishAtLoadingResult = 1
            
            let cacher = JCachedAsync<NSObject, Int>()
            
            var weakNativeLoader = nativeLoader
            var weakCacher       = cacher
            
            let setter = { (value: Int) -> () in
            }
            
            let cachedLoader = cacher.asyncOpWithPropertySetter(setter, getter: {return 1}, uniqueKey: "1", nativeLoader.loader)
            
            var finishResult: Int?
            
            let doneCallback = { (result: JResult<Int>) -> () in
                
                result.onValue { finalResult = $0 }
            }
            
            let cancel = cachedLoader(nil, nil, doneCallback)
            
            XCTAssertEqual(1, finishResult!)
        }
        
        XCTAssertNil(weakNativeLoader )
        XCTAssertNil(weakCacher       )
    }
    
    func testCachedAsyncsCancel()
    {
        weak var weakNativeLoader: JAsyncManager<String>?
        weak var weakCacher: JCachedAsync<String, String>?
        weak var weakResultOrError: AnyObject?
        
        autoreleasepool {
            
            let nativeLoader = JAsyncManager<String>()
            
            let dataOwner = TestClassWithProperties<String>()
            let cacher    = JCachedAsync<String, String>()
            
            var weakNativeLoader = nativeLoader
            var weakCacher       = cacher
            
            autoreleasepool {
                
                let key = "1"
                
                let setter = { (value: String) -> () in
                    dataOwner.dict[key] = value
                }
                
                let getter = { () -> String? in
                    dataOwner.dict[key]
                }
                
                let cachedLoader = cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
                
                var finishError: NSError?
                
                let doneCallback = { (result: JResult<String>) -> () in
                    
                    switch result {
                    result.onError { error -> Void in
                        finishError       = error
                        weakResultOrError = error
                    }
                }
                
                let cancel = cachedLoader(nil, nil, doneCallback)
                
                XCTAssertFalse(nativeLoader.finished)
                XCTAssertFalse(nativeLoader.canceled)
                XCTAssertEqual(nativeLoader.lastHandleFlag, .Undefined)
                
                cancel(task: .Cancel)
                
                XCTAssertTrue (nativeLoader.finished)
                XCTAssertTrue (nativeLoader.canceled)
                XCTAssertEqual(nativeLoader.lastHandleFlag, .Cancel)
                
                XCTAssertNotNil(finishError)
                XCTAssertTrue(finishError! is JAsyncFinishedByCancellationError)
            }
            
            XCTAssertNil(weakResultOrError)
        }
        
        XCTAssertNil(weakNativeLoader )
        XCTAssertNil(weakCacher       )
        XCTAssertNil(weakResultOrError)
    }
    
    func testCachedAsyncsUnsibscribe()
    {
        weak var weakNativeLoader: JAsyncManager<String>?
        weak var weakCacher: JCachedAsync<String, String>?
        
        autoreleasepool {
            
            let nativeLoader = JAsyncManager<String>()
            
            let dataOwner = TestClassWithProperties<String>()
            let cacher    = JCachedAsync<String, String>()
            
            let key = "1"
            
            let setter = { (value: String) -> () in
                dataOwner.dict[key] = value
            }
            
            let getter = { () -> String? in
                dataOwner.dict[key]
            }
            
            let cachedLoader = cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
            
            var finishError: NSError?
            let doneCallback = { (result: JResult<String>) -> () in
                
                result.onError { finishError = $0 }
            }
            
            let cancel = cachedLoader(nil, nil, doneCallback)
            
            XCTAssertFalse(nativeLoader.finished)
            XCTAssertFalse(nativeLoader.canceled)
            XCTAssertEqual(nativeLoader.lastHandleFlag, .Undefined)
            
            cancel(task: .UnSubscribe)
            
            XCTAssertFalse(nativeLoader.finished)
            XCTAssertFalse(nativeLoader.canceled)
            XCTAssertEqual(nativeLoader.lastHandleFlag, .Undefined)
            
            XCTAssertNotNil(finishError)
            XCTAssertTrue(finishError! is JAsyncFinishedByUnsubscriptionError)
            finishError = nil
            
            nativeLoader.loaderHandlerBlock!(task: .UnSubscribe)
            
            XCTAssertNil(finishError)
        }
        
        XCTAssertNil(weakNativeLoader)
        XCTAssertNil(weakCacher      )
    }
    
    func testCachedAsyncsCancelNative()
    {
        weak var weakNativeLoader : JAsyncManager<String>?
        weak var weakCacher       : JCachedAsync<String, String>?
        weak var weakResultOrError: ObjectHolder<String>?
        
        autoreleasepool {
            
            let nativeLoader = JAsyncManager<ObjectHolder<String>>()
            
            let dataOwner = TestClassWithProperties<ObjectHolder<String>>()
            let cacher    = JCachedAsync<String, ObjectHolder<String>>()
            
            let key = "1"
            
            let setter = { (value: ObjectHolder<String>) -> () in
                dataOwner.dict[key] = value
            }
            
            let getter = { () -> ObjectHolder<String>? in
                dataOwner.dict[key]
            }
            
            let cachedLoader = cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<ObjectHolder<String>>) -> () in
                
                switch result {
                case let .Value(v):
                    weakResultOrError = v.value
                case let .Error(error):
                    finishError       = error
                }
            }
            
            let cancel = cachedLoader(nil, nil, doneCallback)
            
            XCTAssertFalse(nativeLoader.finished)
            XCTAssertFalse(nativeLoader.canceled)
            XCTAssertEqual(nativeLoader.lastHandleFlag, .Undefined)
            
            nativeLoader.loaderHandlerBlock!(task: .Cancel)
            
            XCTAssertTrue (nativeLoader.finished)
            XCTAssertTrue (nativeLoader.canceled)
            XCTAssertEqual(nativeLoader.lastHandleFlag, .Cancel)
            
            XCTAssertNotNil(finishError)
            XCTAssertTrue(finishError! is JAsyncFinishedByCancellationError)
            finishError = nil
            
            cancel(task: .Cancel)
            
            XCTAssertNil(finishError)
        }
        
        XCTAssertNil(weakNativeLoader )
        XCTAssertNil(weakCacher       )
        XCTAssertNil(weakResultOrError)
    }
    
    func testCachedAsyncsUnsibscribeNative()
    {
        weak var weakNativeLoader : JAsyncManager<String>?
        weak var weakCacher       : JCachedAsync<String, String>?
        weak var weakResultOrError: ObjectHolder<String>?
        
        autoreleasepool {
            
            let nativeLoader = JAsyncManager<ObjectHolder<String>>()
            
            let dataOwner = TestClassWithProperties<ObjectHolder<String>>()
            let cacher    = JCachedAsync<String, ObjectHolder<String>>()
            
            let key = "1"
            
            let setter = { (value: ObjectHolder<String>) -> () in
                dataOwner.dict[key] = value
            }
            
            let getter = { () -> ObjectHolder<String>? in
                dataOwner.dict[key]
            }
            
            let cachedLoader = cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
            
            var finishError: NSError?
            
            let doneCallback = { (result: JResult<ObjectHolder<String>>) -> () in
                
                switch result {
                case let .Value(v):
                    weakResultOrError = v.value
                case let .Error(error):
                    finishError = error
                }
            }
            
            let cancel = cachedLoader(nil, nil, doneCallback)
            
            XCTAssertFalse(nativeLoader.finished)
            XCTAssertFalse(nativeLoader.canceled)
            XCTAssertEqual(nativeLoader.lastHandleFlag, .Undefined)
            
            nativeLoader.loaderHandlerBlock!(task: .UnSubscribe)
            
            XCTAssertTrue(nativeLoader.finished)
            XCTAssertTrue(nativeLoader.canceled )
            XCTAssertEqual(nativeLoader.lastHandleFlag, .UnSubscribe)
            
            XCTAssertNotNil(finishError)
            XCTAssertTrue(finishError! is JAsyncFinishedByUnsubscriptionError)
            finishError = nil
            
            cancel(task: .UnSubscribe)
            
            XCTAssertNil(finishError)
        }
        
        XCTAssertNil(weakNativeLoader )
        XCTAssertNil(weakCacher       )
        XCTAssertNil(weakResultOrError)
    }
    
    func testCachedAsyncsOnceLoading()
    {
        weak var weakNativeLoader : JAsyncManager<ObjectHolder<String>>?
        weak var weakCacher       : JCachedAsync<String, ObjectHolder<String>>?
        weak var weakResultOrError: ObjectHolder<String>?
        
        autoreleasepool {
            
            let nativeLoader = JAsyncManager<ObjectHolder<String>>()
            
            let dataOwner = TestClassWithProperties<ObjectHolder<String>>()
            let cacher    = JCachedAsync<String, ObjectHolder<String>>()
            
            let key = "1"
            
            let setter = { (value: ObjectHolder<String>) -> () in
                dataOwner.dict[key] = value
            }
            
            let getter = { () -> ObjectHolder<String>? in
                dataOwner.dict[key]
            }
            
            let cachedLoader: JAsyncTypes<ObjectHolder<String>>.JAsync = cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
            
            XCTAssertEqual(nativeLoader.loadingCount, 0)
            
            var finished1 = false
            let cancelCachedLoader1 = cachedLoader(nil, nil, { (result: JResult<ObjectHolder<String>>) -> () in
                result.onValue { finished1 = $0 }
            })
            
            var finished2 = false
            let cancelCachedLoader2 = cachedLoader(nil, nil, { (result: JResult<ObjectHolder<String>>) -> () in
                result.onValue { finished2 = $0 }
            })
            
            let cachedLoader2 = cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
            
            var finished3 = false
            let cancelCachedLoader3 = cachedLoader2(nil, nil, { (result: JResult<ObjectHolder<String>>) -> () in
                result.onValue { finished3 = $0 }
            })
            
            XCTAssertFalse(nativeLoader.finished)
            XCTAssertEqual(nativeLoader.loadingCount, 1)
            XCTAssertFalse(finished1)
            XCTAssertFalse(finished2)
            XCTAssertFalse(finished3)
            
            XCTAssertNil(dataOwner.dict[key])
            
            let strObjectHolder = ObjectHolder(object: "23")
            let result = JResult.value(strObjectHolder)
            nativeLoader.loaderFinishBlock!(result: result)
            
            XCTAssertTrue(nativeLoader.finished)
            XCTAssertTrue(finished1)
            XCTAssertTrue(finished2)
            XCTAssertTrue(finished3)
            
            let res = dataOwner.dict[key]
            XCTAssertNotNil(res)
            XCTAssertTrue(res! === strObjectHolder)
        }
        
        XCTAssertNil(weakNativeLoader )
        XCTAssertNil(weakCacher       )
        XCTAssertNil(weakResultOrError)
    }
    
    //Scenario:
    //1. Create property loader
    //2. Wrap it by unsubscribe on dealloc
    //3. Release owner
    //4. Finish loader -> crash
    //Result - should not crach
    func testUnsubscribeBug()
    {
        autoreleasepool {
            
            weak var weakNativeLoader: JAsyncManager<String>?
            weak var weakDataOwner   : TestClassWithProperties<String>?
            
            autoreleasepool {
                let nativeLoader = JAsyncManager<String>()
                weakNativeLoader = nativeLoader
                
                autoreleasepool {
                    let dataOwner = TestClassWithProperties<String>()
                    weakDataOwner = dataOwner
                    
                    let key = "1"
                    
                    let setter = { (value: String) -> () in
                        dataOwner.dict[key] = value
                    }
                    
                    let getter = { () -> String? in
                        dataOwner.dict[key]
                    }
                    
                    let cachedLoader = dataOwner.cacher.asyncOpWithPropertySetter(setter, getter: getter, uniqueKey: key, nativeLoader.loader)
                    
                    let unsubscribeLoader = dataOwner.loadersOwner.ownedAsync(cachedLoader)
                    
                    let cancel = unsubscribeLoader(nil, nil, nil)
                }
                
                nativeLoader.loaderFinishBlock!(result: JResult.value("res"))
            }
            XCTAssertNil(weakDataOwner   )
            XCTAssertNil(weakNativeLoader)
        }
    }
}
