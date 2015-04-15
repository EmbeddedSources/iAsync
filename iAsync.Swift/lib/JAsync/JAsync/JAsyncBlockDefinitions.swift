//
//  JAsyncBlockDefinitions.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public typealias JAsyncProgressCallback = (progressInfo: AnyObject) -> ()

public typealias JAsyncChangeStateCallback = (state: JAsyncState) -> ()

public typealias JAsyncHandler = (task: JAsyncHandlerTask) -> ()

public enum JAsyncTypes<T> {
    
    public typealias ResultType = T
    public typealias JDidFinishAsyncCallback = (result: JResult<T>) -> ()
    
    public typealias JAsync = (
        progressCallback: JAsyncProgressCallback?,
        stateCallback   : JAsyncChangeStateCallback?,
        finishCallback  : JDidFinishAsyncCallback?) -> JAsyncHandler
    
    //Synchronous block which can take a lot of time
    public typealias JSyncOperation = () -> JResult<T>
    
    //This block should call progress_callback_ block only from own thread
    public typealias JSyncOperationWithProgress = (progressCallback: JAsyncProgressCallback?) -> JResult<T>
}

public enum JAsyncTypes2<T1, T2> {
    
    public typealias BinderType = T1
    public typealias ResultType = T2
    
    public typealias JAsyncBinder = (T1) -> JAsyncTypes<T2>.JAsync

    public typealias JDidFinishAsyncHook = (
        result        : JResult<T1>,
        finishCallback: JAsyncTypes<T2>.JDidFinishAsyncCallback?) -> ()
}
