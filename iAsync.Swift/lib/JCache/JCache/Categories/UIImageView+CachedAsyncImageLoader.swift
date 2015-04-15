//
//  UIImageView+CachedAsyncImageLoader.swift
//  JCache
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import UIKit

private var jffAsycImageURLHolder: Void?

public extension UIImageView {
    
    private var jffAsycImageURL: NSURL? {
        get {
            return objc_getAssociatedObject(self, &jffAsycImageURLHolder) as? NSURL
        }
        set (newValue) {
            objc_setAssociatedObject(self, &jffAsycImageURLHolder, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    private func jffSetImage(image: UIImage?, url: NSURL) {
        
        if image == nil || jffAsycImageURL != url {
            return
        }
        
        self.image = image
    }
    
    func setImageWithURL(url: NSURL?, placeholder: UIImage?) {
        
        image = placeholder
        
        jffAsycImageURL = url
        
        if let url = url {
            
            let doneCallback = { [weak self] (result: JResult<UIImage>) -> () in
                
                if let self_ = self {
                    
                    switch result {
                    case let .Value(v):
                        let image = v.value
                        self_.jffSetImage(image, url:url)
                    case let .Error(error):
                        self_.jffSetImage(nil, url:url)
                    }
                }
            }
            
            let storage = jThumbnailStorage
            let loader  = storage.thumbnailLoaderForUrl(url)
            let cancel  = loader(
                progressCallback: nil,
                stateCallback: nil,
                finishCallback: doneCallback)
        }
    }
}
