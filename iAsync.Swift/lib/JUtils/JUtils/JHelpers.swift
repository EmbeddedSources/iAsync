//
//  JHelpers.swift
//  JUtils
//
//  Created by Vladimir Gorbenko on 11.08.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public func synced<R>(lock: AnyObject, closure: () -> R) -> R {
    objc_sync_enter(lock)
    let result = closure()
    objc_sync_exit(lock)
    return result
}
