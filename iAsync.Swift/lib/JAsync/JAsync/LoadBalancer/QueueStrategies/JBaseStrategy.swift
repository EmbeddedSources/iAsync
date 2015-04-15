//
//  JBaseStrategy.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JBaseStrategy<T> {
    
    typealias ResultType = T
    
    var queueState: JQueueState<ResultType>!
    
    init(queueState: JQueueState<ResultType>) {
        
        self.queueState = queueState
    }
    
    public func executePendingLoader(pendingLoader: JBaseLoaderOwner<T>) {
        
        var objectIndex = Int.max
        
        for (index, loader) in enumerate(queueState.pendingLoaders) {
            if loader === pendingLoader {
                objectIndex = index
                break
            }
        }
        
        if objectIndex != Int.max {
            queueState.pendingLoaders.removeAtIndex(objectIndex)
        }
        
        queueState.activeLoaders.append(pendingLoader)
        
        //    #ifdef DEBUG
        //    NSUInteger pendingLoadersCount = [_queueState->_pendingLoaders count]
        //    NSUInteger activeLoadersCount  = [_queueState->_activeLoaders  count]
        //    #endif //DEBUG
        
        pendingLoader.performLoader()
        
        //    #ifdef DEBUG
        //    NSParameterAssert(pendingLoadersCount >= [_queueState->_pendingLoaders count])
        //    NSParameterAssert(activeLoadersCount  >= [_queueState->_activeLoaders  count])
        //    #endif //DEBUG
    }
}
