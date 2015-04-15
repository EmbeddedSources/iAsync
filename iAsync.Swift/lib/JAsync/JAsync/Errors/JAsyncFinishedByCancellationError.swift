//
//  JAsyncFinishedByCancellationError.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JAsyncFinishedByCancellationError: JAsyncAbstractFinishError {
    
    public init() {
        
        let str = "JFF_ASYNC_OPERATION_FINISHED_BY_CANCELLATION_ERROR"
        super.init(description: str)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class func jffErrorsDomain() -> String {
        
        return "com.just_for_fun.async_canceled.jff_async_operations.library"
    }
    
    public override func writeErrorWithJLogger () {}
}
