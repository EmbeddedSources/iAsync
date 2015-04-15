//
//  JNetworkResponseDataCallback.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JNetworkResponseDataCallback {
    
    public let dataChunk: NSData
    
    public let downloadedBytesCount: Int64
    public let totalBytesCount: Int64
    
    public init(dataChunk: NSData, downloadedBytesCount: Int64, totalBytesCount: Int64) {
        
        self.dataChunk            = dataChunk
        self.downloadedBytesCount = downloadedBytesCount
        self.totalBytesCount      = totalBytesCount
    }
}
