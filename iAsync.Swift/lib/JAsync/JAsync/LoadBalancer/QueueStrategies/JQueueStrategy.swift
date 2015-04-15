//
//  JQueueStrategy.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public protocol JQueueStrategy {
    
    typealias ResultType : Any
    
    init(queueState: JQueueState<ResultType>)
    
    func firstPendingLoader() -> JBaseLoaderOwner<ResultType>?
    func executePendingLoader(pendingLoader: JBaseLoaderOwner<ResultType>)
}
