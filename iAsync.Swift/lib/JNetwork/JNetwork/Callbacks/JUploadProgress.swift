//
//  JUploadProgress.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

protocol JUploadProgress : NSObjectProtocol {
    
    var progress: Float { get }
    var url: NSURL { get }
    var headers: NSDictionary? { get }
}
