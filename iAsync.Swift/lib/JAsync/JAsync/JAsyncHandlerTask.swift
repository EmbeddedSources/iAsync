//
//  JAsyncHandlerTask.swift
//  JAsync
//
//  Created by Vladimir Gorbenko on 11.06.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

@objc public enum JAsyncHandlerTask : UInt {
    case UnSubscribe
    case Cancel
    case Resume
    case Suspend
    case Undefined
}
