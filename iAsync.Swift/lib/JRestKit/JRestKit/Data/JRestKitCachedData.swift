//
//  JRestKitCachedData.swift
//  JRestKit
//
//  Created by Vladimir Gorbenko on 22.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public protocol JRestKitCachedData : NSObjectProtocol {
    
    var data: NSData { get }
    var updateDate: NSDate? { get }
}
