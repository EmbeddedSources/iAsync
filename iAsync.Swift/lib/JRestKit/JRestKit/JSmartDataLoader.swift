//
//  JSmartDataLoader.swift
//  JRestKit
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils

extension NSObject {
    
    //TODO give him long name
    func logResponse() {
        NSLog("jsResponse: \(self)")
    }
}

extension NSData {
    
    override func logResponse() {
        
        let str = NSString(data:self, encoding:NSUTF8StringEncoding)
        NSLog("jsResponse: \(str) length: \(length)")
    }
}

public class JSmartDataLoaderFields<Identifier, Result> {
    
    public typealias JAsyncBinderForIdentifier = (loadDataIdentifier: Identifier) -> JAsyncTypes2<NSData, Result>.JAsyncBinder
    public typealias JCacheKeyForIdentifier    = (loadDataIdentifier: Identifier) -> String
    
    let loadDataIdentifier: Identifier
    let dataLoaderForIdentifier: JAsyncTypes2<Identifier, NSData>.JAsyncBinder
    let analyzerForData: JAsyncBinderForIdentifier
    let cacheKeyForIdentifier: JCacheKeyForIdentifier
    let doesNotIgnoreFreshDataLoadFail: Bool
    let cache: JAsyncRestKitCache
    let cacheDataLifeTimeInSeconds: NSTimeInterval
    
    public init(
        loadDataIdentifier: Identifier,
        dataLoaderForIdentifier: JAsyncTypes2<Identifier, NSData>.JAsyncBinder,
        analyzerForData: JAsyncBinderForIdentifier,
        cacheKeyForIdentifier: JCacheKeyForIdentifier,
        doesNotIgnoreFreshDataLoadFail: Bool,
        cache: JAsyncRestKitCache,
        cacheDataLifeTimeInSeconds: NSTimeInterval)
    {
        self.loadDataIdentifier             = loadDataIdentifier
        self.dataLoaderForIdentifier        = dataLoaderForIdentifier
        self.analyzerForData                = analyzerForData
        self.cacheKeyForIdentifier          = cacheKeyForIdentifier
        self.doesNotIgnoreFreshDataLoadFail = doesNotIgnoreFreshDataLoadFail
        self.cache                          = cache
        self.cacheDataLifeTimeInSeconds     = cacheDataLifeTimeInSeconds
    }
}

public func jSmartDataLoaderWithCache<Identifier, Result>(args: JSmartDataLoaderFields<Identifier, Result>) -> JAsyncTypes<Result>.JAsync {
    
    let loadDataIdentifier             = args.loadDataIdentifier
    let dataLoaderForIdentifier        = args.dataLoaderForIdentifier
    let analyzerForData                = args.analyzerForData
    let cache                          = args.cache
    let cacheKeyForIdentifier          = args.cacheKeyForIdentifier
    let cacheDataLifeTimeInSeconds     = args.cacheDataLifeTimeInSeconds
    let doesNotIgnoreFreshDataLoadFail = args.doesNotIgnoreFreshDataLoadFail
    
    let key = cacheKeyForIdentifier(loadDataIdentifier: loadDataIdentifier)
    
    let cachedDataLoader = { (progressCallback: JAsyncProgressCallback?,
                              stateCallback: JAsyncChangeStateCallback?,
                              finishCallback: JAsyncTypes<JRestKitCachedData>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let loadCachedData = loadFreshCachedDataWithUpdateDate(
            key,
            cache.cachedDataLoaderForKey(key),
            cacheDataLifeTimeInSeconds)
        
        let dataLoaderBinder = dataLoaderWithCachedResultBinder(
            doesNotIgnoreFreshDataLoadFail,
            dataLoaderForIdentifier,
            loadDataIdentifier)
        
        let loader = bindTrySequenceOfAsyncs(loadCachedData, dataLoaderBinder)
        
        return loader(
            progressCallback: progressCallback,
            stateCallback: stateCallback,
            finishCallback: finishCallback)
    }
    
    let analyzer = { (response: JRestKitCachedData) -> JAsyncTypes<Result>.JAsync in
        
        let binder = analyzerForData(loadDataIdentifier: loadDataIdentifier)
        
        let analyzer = binder(response.data)
        
        let cacheBinder = { (analyzedData: Result) -> JAsyncTypes<Result>.JAsync in
            
            let resultLoader = asyncWithResult(analyzedData)
            
            if response.updateDate == nil {
                let loader = cache.loaderToSetData(response.data, forKey:key)
                return sequenceOfAsyncs(loader, resultLoader)
            }
            return resultLoader
        }
        
        return bindSequenceOfAsyncs(analyzer, cacheBinder)
    }
    
    return bindSequenceOfAsyncs(cachedDataLoader, analyzer)
}

internal class JErrorNoFreshData : JError {
    
    let cachedData: JRestKitCachedData!
    
    override class func jffErrorsDomain() -> String {
        return "com.just_for_fun.rest_kit_internal.library"
    }
    
    required init(cachedData: JRestKitCachedData) {
        
        self.cachedData = cachedData
        super.init(description: "internal logic error (no fresh data)")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(cachedData: cachedData)
    }
}

private func dataLoaderWithCachedResultBinder<Identifier>(
    doesNotIgnoreFreshDataLoadFail: Bool,
    dataLoaderForIdentifier: JAsyncTypes2<Identifier, NSData>.JAsyncBinder,
    loadDataIdentifier: Identifier) -> JAsyncTypes2<NSError, JRestKitCachedData>.JAsyncBinder
{
    return { (bindError: NSError) -> JAsyncTypes<JRestKitCachedData>.JAsync in
        
        let finishCallbackHook = { (result: JResult<NSData>, doneCallback: JAsyncTypes<JRestKitCachedData>.JDidFinishAsyncCallback?) -> () in
            
            switch result {
            case let .Value(v):
                //logs [ srvResponse_ logResponse ];
                let newResult = JResponseDataWithUpdateData(data: v.value, updateDate: nil)
                doneCallback?(result: JResult.value(newResult))
            case let .Error(error):
                //TODO test [bindError isKindOfClass:[JFFErrorNoFreshData class]] issue, here it can got - not data in cache error !!!
                if !doesNotIgnoreFreshDataLoadFail {
                    if let noFreshDataError = bindError as? JErrorNoFreshData {
                    
                        let newResult = JResponseDataWithUpdateData(
                            data: noFreshDataError.cachedData.data,
                            updateDate: noFreshDataError.cachedData.updateDate)
                    
                        doneCallback?(result: JResult.value(newResult))
                        return
                    }
                }
                
                doneCallback?(result: JResult.error(error))
            }
        }
        let dataLoader = dataLoaderForIdentifier(loadDataIdentifier)
        return asyncWithFinishHookBlock(dataLoader, finishCallbackHook)
    }
}

private func loadFreshCachedDataWithUpdateDate(
    key: String,
    cachedDataLoader: JAsyncTypes<JRestKitCachedData>.JAsync,
    cacheDataLifeTimeInSeconds: NSTimeInterval) -> JAsyncTypes<JRestKitCachedData>.JAsync
{
    let validateByDateResultBinder = { (cachedData: JRestKitCachedData) -> JAsyncTypes<JRestKitCachedData>.JAsync in
        
        let newDate = cachedData.updateDate?.dateByAddingTimeInterval(cacheDataLifeTimeInSeconds)
        if newDate!.compare(NSDate()) == NSComparisonResult.OrderedDescending {
            return asyncWithResult(cachedData)
        }
        
        let error = JErrorNoFreshData(cachedData: cachedData)
        return asyncWithError(error)
    }
    
    return bindSequenceOfAsyncs(cachedDataLoader, validateByDateResultBinder)
}
