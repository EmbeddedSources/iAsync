//
//  JStrategyFifo.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JStrategyFifo<T> : JBaseStrategy<T>, JQueueStrategy {
    
    required override public init(queueState: JQueueState<ResultType>) {
        super.init(queueState: queueState)
    }
    
    public func firstPendingLoader() -> JBaseLoaderOwner<ResultType>? {
        
        let result = queueState.pendingLoaders[0]
        return result
    }
}
