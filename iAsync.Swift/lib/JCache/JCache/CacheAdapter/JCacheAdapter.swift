//
//  JCacheAdapter.swift
//  JRestKit
//
//  Created by Vladimir Gorbenko on 05.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import JRestKit
import JAsync

public typealias JCacheFactory = () -> JCacheDB

public class JCacheAdapter : JAsyncRestKitCache {
    
    private let cacheFactory: JCacheFactory
    private let cacheQueueName: String
    
    public init(cacheFactory: JCacheFactory, cacheQueueName: String) {
        
        self.cacheQueueName = cacheQueueName
        self.cacheFactory   = cacheFactory
    }
    
    public func loaderToSetData(data: NSData, forKey key: String) -> JAsyncTypes<NSNull>.JAsync {
        
        return asyncWithSyncOperationAndQueue({ () -> JResult<NSNull> in
            
            self.cacheFactory().setData(data, forKey:key)
            return JResult.value(NSNull())
        }, cacheQueueName)
    }
    
    public func cachedDataLoaderForKey(key: String) -> JAsyncTypes<JRestKitCachedData>.JAsync {
    
        return asyncWithSyncOperationAndQueue({ () -> JResult<JRestKitCachedData> in
            
            let result = self.cacheFactory().dataAndLastUpdateDateForKey(key)
            
            if let result = result {
                let result = JResponseDataWithUpdateData(data: result.0, updateDate: result.1)
                return JResult.value(result)
            }
            
            let description = "no cached data for key: \(key)"
            return JResult.error(JError(description:description))
        }, cacheQueueName)
    }
}
