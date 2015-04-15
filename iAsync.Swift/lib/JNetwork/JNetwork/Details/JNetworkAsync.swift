//
//  JNetworkAsync.swift
//  JNetwork
//
//  Created by Vladimir Gorbenko on 26.09.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JAsync
import JUtils

internal typealias JNetworkErrorTransformer = (error: NSError) -> NSError

internal class JNetworkAsync : JAsyncInterface {

    typealias ResultType = NSHTTPURLResponse
    
    private let params          : JURLConnectionParams
    private let responseAnalyzer: JUtilsBlockDefinitions2<ResultType, ResultType>.JAnalyzer?
    private let errorTransformer: JNetworkErrorTransformer?
    
    private var connection : JURLConnection?
    
    init(
        params          : JURLConnectionParams,
        responseAnalyzer: JUtilsBlockDefinitions2<ResultType, ResultType>.JAnalyzer?,
        errorTransformer: JNetworkErrorTransformer?)
    {
        self.params           = params
        self.responseAnalyzer = responseAnalyzer
        self.errorTransformer = errorTransformer
    }
    
    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        let connection  = JNSURLConnection(params:self.params)
        self.connection = connection
        
        connection.shouldAcceptCertificateBlock = self.params.certificateCallback
        
        unowned(unsafe) let unretainedSelf = self
        
        connection.didReceiveDataBlock = { (dataChunk: NSData) -> () in
            
            let progressData = JNetworkResponseDataCallback(
                dataChunk: dataChunk,
                downloadedBytesCount: connection.downloadedBytesCount,
                totalBytesCount: connection.totalBytesCount)
            
            progressCallback(progressInfo: progressData)
        }
        
        connection.didUploadDataBlock = { (progress: Float) -> () in
            
            let uploadProgress = JNetworkUploadProgressCallback(params: unretainedSelf.params, progress: progress)
            progressCallback(progressInfo: uploadProgress)
        }
        
        var resultHolder: ResultType?
        
        let errorTransformer = self.errorTransformer
        
        let finish = { (error: NSError?) -> () in
        
            if let error = error {
                
                let passError = { () -> NSError in
                    
                    if let errorTransformer = errorTransformer {
                        return errorTransformer(error: error)
                    }
                    return error
                }()
                
                finishCallback(result: JResult.error(passError))
                return
            }
        
            finishCallback(result: JResult.value(resultHolder!))
        }
        
        connection.didFinishLoadingBlock = finish
        
        connection.didReceiveResponseBlock = { (response: NSHTTPURLResponse) -> () in
            
            
            if let responseAnalyzer = unretainedSelf.responseAnalyzer {
                
                let result = responseAnalyzer(object: response)
                
                switch result {
                case let .Value(v):
                    resultHolder = v.value
                case let .Error(error):
                    unretainedSelf.forceCancel()
                    finish(error)
                }
                return
            }
            
            resultHolder = response
            
        }
        
        connection.start()
    }
    
    func doTask(task: JAsyncHandlerTask) {
        
        if let connection = connection {
            
            connection.didReceiveDataBlock          = nil
            connection.didFinishLoadingBlock        = nil
            connection.didReceiveResponseBlock      = nil
            connection.didUploadDataBlock           = nil
            connection.shouldAcceptCertificateBlock = nil
            
            //TODO maybe always cancel?
            if task == .Cancel {
                connection.cancel()
                self.connection = nil
            }
        }
    }
    
    private func forceCancel() {
        
        doTask(.Cancel)
    }
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
}
