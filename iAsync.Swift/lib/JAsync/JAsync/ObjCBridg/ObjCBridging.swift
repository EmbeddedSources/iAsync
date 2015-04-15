//
//  ObjCBridging.swift
//  JAsyncOperations
//
//  Created by Vladimir Gorbenko on 12.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import JAsync

public typealias JObjcAsyncOperationProgressCallback = (AnyObject!) -> ()

public typealias JObjcAsyncOperationChangeStateCallback = (JAsyncState) -> ()

public typealias JObjcDidFinishAsyncOperationCallback = (AnyObject!, NSError!) -> ()

public typealias JObjcAsyncOperationHandler = (JAsyncHandlerTask) -> ()

public typealias JObjcAsyncOperation = (progressCallback: JObjcAsyncOperationProgressCallback!,
    stateCallback   : JObjcAsyncOperationChangeStateCallback!,
    finishCallback  : JObjcDidFinishAsyncOperationCallback!) -> JObjcAsyncOperationHandler!

public typealias JObjcAsyncOperationBinder = (result: AnyObject!) -> JObjcAsyncOperation

public func bridgToObjc<T>(loader: JAsyncTypes<T>.JAsync, nsNullResponse: Bool) -> JObjcAsyncOperation {
    
    return { (progressCallback: JObjcAsyncOperationProgressCallback!,
        stateCallback   : JObjcAsyncOperationChangeStateCallback!,
        finishCallback  : JObjcDidFinishAsyncOperationCallback!) -> JObjcAsyncOperationHandler! in
        
        let finishCallbackWrapper = { (result: JResult<T>) -> () in
            
            if finishCallback != nil {
                
                switch result {
                case let .Value(v):
                    if nsNullResponse {
                        finishCallback(NSNull(), nil)
                    } else {
                        finishCallback(v.value as! NSObject, nil)
                    }
                case let .Error(error):
                    finishCallback(nil, error)
                }
            }
        }
        
        return loader(
            progressCallback: progressCallback,
            stateCallback   : stateCallback   ,
            finishCallback  : finishCallbackWrapper)
    }
}

public func bridgFromObjc<T>(loader: JObjcAsyncOperation) -> JAsyncTypes<T>.JAsync {
    
    return { (progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JAsyncTypes<T>.JDidFinishAsyncCallback?) -> JAsyncHandler in
        
        let progressCallbackWrapper = { (progressInfo: AnyObject!) -> () in
            
            if progressInfo != nil {
                progressCallback?(progressInfo: progressInfo)
            }
        }
        
        let finishCallbackWrapper = { (result: AnyObject!, error: NSError!) -> () in
            
            if let finishCallback = finishCallback {
                
                if result != nil {
                    
                    finishCallback(result: JResult.value(result as! T))
                } else {
                    
                    finishCallback(result: JResult.error(error))
                }
            }
        }
        
        return loader(
            progressCallback: progressCallbackWrapper,
            stateCallback   : stateCallback          ,
            finishCallback  : finishCallbackWrapper)
    }
}

public func bridgToObjcBinder<T1, T2>(binder: JAsyncTypes2<T1, T2>.JAsyncBinder) -> JObjcAsyncOperationBinder {
    
    return { (result: AnyObject!) -> JObjcAsyncOperation in
        
        return bridgToObjc(binder(result as! T1), false)
    }
}

public func bridgFromObjcBinder<T1, T2>(binder: JObjcAsyncOperationBinder) -> JAsyncTypes2<T1, T2>.JAsyncBinder {
    
    return { (result: T1) -> JAsyncTypes<T2>.JAsync in
        
        return bridgFromObjc(binder(result: result as! AnyObject))
    }
}
