//
//  JThumbnailStorage.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JNetwork
import JRestKit
import JAsync
import JUtils

import UIKit

private let cacheQueueName = "com.embedded_sources.jffcache.thumbnail_storage.cache"

private let noDataUrlStr = "nodata://jff.cache.com"

public extension NSURL {

    public class var noImageDataURL: NSURL {
        struct Static {
            static let instance = NSURL(string: noDataUrlStr)!
        }
        return Static.instance
    }
    
    public var isNoImageDataURL: Bool {
        return self.absoluteString == noDataUrlStr
    }
}

public var jThumbnailStorage = JThumbnailStorage()

public class JThumbnailStorage : NSObject {
    
    private override init() {
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("onMemoryWarning:"),
            name: UIApplicationDidReceiveMemoryWarningNotification,
            object: nil)
    }
    
    private let cachedAsyncOp = JCachedAsync<NSURL, UIImage>()
    private let imagesByUrl   = NSCache()
    
    //TODO add load balancer here
    public func thumbnailLoaderForUrl(url: NSURL?) -> JAsyncTypes<UIImage>.JAsync {
        
        if let url = url {
            
            if url.isNoImageDataURL {
                return asyncWithError(JCacheNoURLError())
            }
            
            let loader = { (progressCallback: JAsyncProgressCallback?,
                            stateCallback: JAsyncChangeStateCallback?,
                            doneCallback: JAsyncTypes<UIImage>.JDidFinishAsyncCallback?) -> JAsyncHandler in
                
                let imageLoader = self.cachedInDBImageDataLoaderForUrl(url)
                
                let setter = { (value: UIImage) -> () in
                    self.imagesByUrl.setObject(value, forKey: url)
                }
                
                let getter = { () -> UIImage? in
                    return self.imagesByUrl.objectForKey(url) as? UIImage
                }
                
                let loader = self.cachedAsyncOp.asyncOpWithPropertySetter(
                    setter,
                    getter   : getter,
                    uniqueKey: url   ,
                    loader   : imageLoader)
                
                return loader(
                    progressCallback: progressCallback,
                    stateCallback: stateCallback,
                    finishCallback: doneCallback)
            }
            
            return logErrorForLoader(loader)
        }
        
        return asyncWithError(JCacheNoURLError())
    }
    
    public func tryThumbnailLoaderForUrls(urls: [NSURL]) -> JAsyncTypes<UIImage>.JAsync {
        
        if urls.count == 0 {
            return asyncWithError(JCacheNoURLError())
        }
        
        let loaders = urls.map { (url: NSURL) -> JAsyncTypes<UIImage>.JAsync in

            return self.thumbnailLoaderForUrl(url)
        }
    
        return trySequenceOfAsyncsArray(loaders)
    }
    
    public func resetCache() {
        
        imagesByUrl.removeAllObjects()
    }
    
    private func cachedInDBImageDataLoaderForUrl(url: NSURL) -> JAsyncTypes<UIImage>.JAsync {
        
        let dataLoaderForIdentifier = { (url: NSURL) -> JAsyncTypes<NSData>.JAsync in

            let dataLoader = dataURLResponseLoader(url, nil, nil)
            return dataLoader
        }
        
        let cacheKeyForIdentifier = { (loadDataIdentifier: NSURL) -> String in
            
            return loadDataIdentifier.absoluteString!
        }
        
        let args = JSmartDataLoaderFields(
            loadDataIdentifier:url,
            dataLoaderForIdentifier:dataLoaderForIdentifier,
            analyzerForData:imageDataToUIImageBinder(),
            cacheKeyForIdentifier:cacheKeyForIdentifier,
            doesNotIgnoreFreshDataLoadFail:false,
            cache:createImageCacheAdapter(),
            cacheDataLifeTimeInSeconds:self.dynamicType.cacheDataLifeTimeInSeconds)

        let loader = jSmartDataLoaderWithCache(args)

        return bindTrySequenceOfAsyncs(loader, { (error: NSError) -> JAsyncTypes<UIImage>.JAsync in
            
            let resultError = JCacheLoadImageError(nativeError: error)
            return asyncWithError(resultError)
        })
    }

    private class var cacheDataLifeTimeInSeconds: NSTimeInterval {
        
        let dbInfoByNames = JCaches.sharedCaches().dbInfo.dbInfoByNames
        let info = dbInfoByNames.infoByDBName(JCaches.thumbnailDBName())!
        return info.timeToLiveInHours * 3600.0
    }
    
    private class JImageCacheAdapter : JCacheAdapter {
    
        init() {
            
            let cacheFactory = { () -> JCacheDB in
                return JCaches.sharedCaches().createThumbnailDB()
            }
            
            super.init(cacheFactory: cacheFactory, cacheQueueName: cacheQueueName)
        }
    
        override func loaderToSetData(data: NSData, forKey key: String) -> JAsyncTypes<NSNull>.JAsync {
            
            let loader = super.loaderToSetData(data, forKey:key)
            return Transformer.transformLoadersType1(loader, transformer: balanced)
        }
    
        override func cachedDataLoaderForKey(key: String) -> JAsyncTypes<JRestKitCachedData>.JAsync {
            
            let loader = super.cachedDataLoaderForKey(key)
            return Transformer.transformLoadersType2(loader, transformer: balanced)
        }
    }
    
    private func createImageCacheAdapter() -> JImageCacheAdapter {
    
        let result = JImageCacheAdapter()
        return result
    }

    public func onMemoryWarning(notification: NSNotification) {
        
        resetCache()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//TODO try to use NSURLCache
private func imageDataToUIImageBinder() -> JSmartDataLoaderFields<NSURL, UIImage>.JAsyncBinderForIdentifier
{
    return { (url: NSURL) -> JAsyncTypes2<NSData, UIImage>.JAsyncBinder in
        
        return { (imageData: NSData) -> JAsyncTypes<UIImage>.JAsync in
            
            let image = UIImage(data: imageData)
            
            if let image = image {
                return asyncWithResult(image)
            }
            
            let error = JCanNotCreateImageError(url: url)
            return asyncWithError(error)
        }
        // TODO: Test perfomance
        //        return ^JFFAsyncOperation(NSData *imageData) {
        //            return asyncWithSyncOperation(^id(NSError *__autoreleasing *outError) {
        //                UIImage *image = [UIImage imageWithData:imageData];
        //
        //                if (!image) {
        //                    *outError = [JFFCanNotCreateImageError new];
        //                }
        //                return image;
        //            });
        //        };
    }
}

private typealias Transformer = JAsyncTypesTransform<NSNull, JRestKitCachedData>

private func balanced(loader: JAsyncTypes<Transformer.PackedType>.JAsync) -> JAsyncTypes<Transformer.PackedType>.JAsync
{
    return cacheBalancer().balancedLoaderWithLoader(loader, barrier:false)
}

//TODO refactor this
private func cacheBalancer() -> JLimitedLoadersQueue<JStrategyFifo<Transformer.PackedType>>
{
    struct Static {
        static let instance = JLimitedLoadersQueue<JStrategyFifo<Transformer.PackedType>>()
    }
    return Static.instance
}
