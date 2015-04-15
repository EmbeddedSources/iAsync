//
//  JURLConnection.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 25.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

public protocol JURLConnection : NSObjectProtocol {

    func start()
    func cancel()

    var downloadedBytesCount: Int64 { get }
    var totalBytesCount     : Int64 { get }

    //callbacks cleared after finish of loading
    var didReceiveResponseBlock     : JDidReceiveResponseHandler?      { get set }
    var didReceiveDataBlock         : JDidReceiveDataHandler?          { get set }
    var didFinishLoadingBlock       : JDidFinishLoadingHandler?        { get set }
    var didUploadDataBlock          : JDidUploadDataHandler?           { get set }
    var shouldAcceptCertificateBlock: JShouldAcceptCertificateForHost? { get set }
}
