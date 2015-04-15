//
//  JBaseLoaderOwner.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public class JBaseLoaderOwner<T> {
    
    var barrier = false
    
    var loader: JAsyncTypes<T>.JAsync!
    
    var loadersHandler  : JAsyncHandler?
    var progressCallback: JAsyncProgressCallback?
    var stateCallback   : JAsyncChangeStateCallback?
    var doneCallback    : JAsyncTypes<T>.JDidFinishAsyncCallback?
    
    typealias FinishCallback = (JBaseLoaderOwner<T>) -> ()
    private var didFinishActiveLoaderCallback: FinishCallback?
    
    init(loader: JAsyncTypes<T>.JAsync, didFinishActiveLoaderCallback: FinishCallback) {
        
        self.loader = loader
        self.didFinishActiveLoaderCallback = didFinishActiveLoaderCallback
    }
    
    func performLoader() {
        
        assert(loadersHandler == nil)
        
        let progressCallbackWrapper = { (progress: AnyObject) -> () in
            
            self.progressCallback?(progressInfo: progress)
            return
        }
        
        let stateCallbackWrapper = { (state: JAsyncState) -> () in
            
            self.stateCallback?(state: state)
            return
        }
        
        let doneCallbackWrapper = { (result: JResult<T>) -> () in
            
            self.didFinishActiveLoaderCallback?(self)
            
            self.doneCallback?(result: result)
            
            self.clear()
        }
        
        loadersHandler = loader(
            progressCallback: progressCallbackWrapper,
            stateCallback: stateCallbackWrapper,
            finishCallback: doneCallbackWrapper)
    }
    
    private func clear() {
        
        loader           = nil
        didFinishActiveLoaderCallback = nil
        loadersHandler   = nil
        progressCallback = nil
        stateCallback    = nil
        doneCallback     = nil
    }
}
