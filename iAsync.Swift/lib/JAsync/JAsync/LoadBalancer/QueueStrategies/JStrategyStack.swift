//
//  JStrategyStack.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

internal class JStrategyStack<T> : JBaseStrategy<T>, JQueueStrategy {
    
    required override init(queueState: JQueueState<ResultType>) {
        super.init(queueState: queueState)
    }
    
    func firstPendingLoader() -> JBaseLoaderOwner<T>? {
        
        let result = queueState.pendingLoaders.last
        return result
    }
}
