//
//  JAbstractConnection.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public class JAbstractConnection : NSObject, JURLConnection {
    
    public func start() {
        
        assert(false, "not implemented")
    }
    
    public func cancel() {
        
        assert(false, "not implemented")
    }
    
    public var downloadedBytesCount: Int64 {
        assert(false, "not implemented")
        return 0
    }
    
    public var totalBytesCount: Int64 {
        assert(false, "not implemented")
        return 0
    }
    
    func clearCallbacks() {
        
        didReceiveResponseBlock      = nil
        didReceiveDataBlock          = nil
        didFinishLoadingBlock        = nil
        didUploadDataBlock           = nil
        shouldAcceptCertificateBlock = nil
    }
    
    public var didReceiveResponseBlock     : JDidReceiveResponseHandler?
    public var didReceiveDataBlock         : JDidReceiveDataHandler?
    public var didFinishLoadingBlock       : JDidFinishLoadingHandler?
    public var didUploadDataBlock          : JDidUploadDataHandler?
    public var shouldAcceptCertificateBlock: JShouldAcceptCertificateForHost?
}
