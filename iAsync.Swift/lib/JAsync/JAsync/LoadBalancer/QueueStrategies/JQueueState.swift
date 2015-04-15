//
//  JQueueState.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 09.07.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JQueueState<T>  {
    var activeLoaders  = [JBaseLoaderOwner<T>]()
    var pendingLoaders = [JBaseLoaderOwner<T>]()
}
