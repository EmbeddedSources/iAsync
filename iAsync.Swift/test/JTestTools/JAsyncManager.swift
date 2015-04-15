//
//  JAsyncManager.swift
//  JAsyncTests
//
//  Created by Vladimir Gorbenko on 20.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils

enum JCancelAsyncManagerType : UInt {
    case DoNotCancel
    case CancelWithNoFlag
    case CancelWithYesFlag
}

class JAsyncManager<T> {

    var finishAtLoadingResult: T? = nil
    var failAtLoadingError   : NSError?   = nil
    var cancelAtLoading = JCancelAsyncManagerType.DoNotCancel
    
    var loader: JAsyncTypes<T>.JAsync {
        return { (progressCallback: JAsyncProgressCallback?,
                  stateCallback   : JAsyncChangeStateCallback?,
                  finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
            
            weak var weakSelf = self
            
            self.loadingCount += 1
            
            if self.cancelAtLoading.rawValue > JCancelAsyncManagerType.DoNotCancel.rawValue {
                
                self.canceled = true
                if let finish = finishCallback {
                    
                    let task: JAsyncHandlerTask = self.cancelAtLoading == .CancelWithNoFlag
                        ?.UnSubscribe
                        :.Cancel
                    let error = JAsyncAbstractFinishError.buildFinishError(task)
                    finish(result: JResult.error(error!))
                }
                return jStubHandlerAsyncBlock
            }
            
            let loaderFinishBlock = { (result: JResult<T>) -> () in
                
                if let self_ = weakSelf {
                    
                    self_.loaderFinishBlock  = nil
                    self_.loaderHandlerBlock = nil
                    self_.finished = true
                }
                finishCallback?(result: result)
            }
            
            self.loaderFinishBlock = loaderFinishBlock
            
            if self.finishAtLoadingResult != nil || self.failAtLoadingError != nil {
                if let result : T = self.finishAtLoadingResult {
                    loaderFinishBlock(JResult.value(result))
                } else {
                    loaderFinishBlock(JResult.error(self.failAtLoadingError!))
                }
                return jStubHandlerAsyncBlock
            }
            
            let loaderHandlerBlock = { (task: JAsyncHandlerTask) -> () in
                
                var finish: JAsyncTypes<T>.JDidFinishAsyncCallback?
                if let self_ = weakSelf {
                    if task.rawValue <= .Cancel.rawValue {
                        finish = self_.loaderFinishBlock
                        self_.loaderFinishBlock  = nil
                        self_.loaderHandlerBlock = nil
                    }

                    self_.canceled       = task.rawValue <= .Cancel.rawValue
                    self_.lastHandleFlag = task
                }
                processHandlerFlag(task, stateCallback, finish)
            }
            self.loaderHandlerBlock = loaderHandlerBlock

            return loaderHandlerBlock
        }
    }
    
    var loaderFinishBlock : JAsyncTypes<T>.JDidFinishAsyncCallback? = nil
    var loaderHandlerBlock: JAsyncHandler? = nil
    
    var loadingCount = 0
    var finished     = false
    var canceled     = false

    var lastHandleFlag = JAsyncHandlerTask.Undefined
    
    func clear() {
        
        loaderFinishBlock  = nil
        loaderHandlerBlock = nil
        finished           = false
        loadingCount       = 0
        
        lastHandleFlag = .Undefined
    }
}
