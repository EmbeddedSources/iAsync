//
//  JAsyncAbstractFinishError.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JAsyncAbstractFinishError: JAsyncError {
    
    public class func buildFinishError(handlerTask: JAsyncHandlerTask) -> JAsyncAbstractFinishError? {
        
        switch handlerTask {
            
        case .Cancel:
            return JAsyncFinishedByCancellationError()
        case .UnSubscribe:
            return JAsyncFinishedByUnsubscriptionError()
        default:
            return nil
        }
    }
}
