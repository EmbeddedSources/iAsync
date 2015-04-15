//
//  JURLConnectionCallbacks.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public typealias JDidReceiveResponseHandler      = (response: NSHTTPURLResponse) -> ()
public typealias JDidFinishLoadingHandler        = (error: NSError?) -> ()
public typealias JDidReceiveDataHandler          = (data: NSData) -> ()
public typealias JDidUploadDataHandler           = (progress: Float) -> ()
public typealias JShouldAcceptCertificateForHost = (host: String) -> Bool
