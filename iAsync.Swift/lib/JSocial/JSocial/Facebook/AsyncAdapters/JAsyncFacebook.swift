//
//  JAsyncFacebook.swift
//  JSocial
//
//  Created by Vladimir Gorbenko on 09.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import JAsync

import FBSDKCoreKit
import FBSDKLoginKit

private class JFacebookGeneralRequestLoader : JAsyncInterface {

    private var requestConnection: FBSDKGraphRequestConnection?
    
    private let accessToken: FBSDKAccessToken
    private let graphPath  : String
    private let httpMethod : String?
    private let parameters : [String:AnyObject]?
    
    init(
        accessToken: FBSDKAccessToken,
        graphPath  : String,
        httpMethod : String?,
        parameters : [String:AnyObject]?)
    {
        self.accessToken = accessToken
        self.graphPath   = graphPath
        self.httpMethod  = httpMethod
        self.parameters  = parameters
    }
    
    typealias ResultType = NSDictionary
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
    
    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        let fbRequest = FBSDKGraphRequest(
            graphPath  : graphPath ,
            parameters : parameters,
            tokenString: accessToken.tokenString,
            version    : nil,
            HTTPMethod : httpMethod)
        
        requestConnection = fbRequest.startWithCompletionHandler { (
            connection : FBSDKGraphRequestConnection!,
            graphObject: AnyObject!,
            error      : NSError!) -> Void in
            
            if let graphObject = graphObject as? NSDictionary {
                
                finishCallback(result: JResult.value(graphObject))
            } else {
                
                finishCallback(result: JResult.error(error))
            }
        }
    }
    
    func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
        if task == JAsyncHandlerTask.Cancel {
            
            if let requestConnection = requestConnection {
                self.requestConnection = nil
                requestConnection.cancel()
            }
        }
    }
}

func jffGenericFacebookGraphRequestLoader(
    accessToken: FBSDKAccessToken,
    graphPath  : String,
    httpMethod : String?,
    parameters : [String:AnyObject]?) -> JAsyncTypes<NSDictionary>.JAsync
{
    let factory = { () -> JFacebookGeneralRequestLoader in

        let object = JFacebookGeneralRequestLoader(
            accessToken: accessToken,
            graphPath  : graphPath  ,
            httpMethod : httpMethod ,
            parameters : parameters
        )
        return object
    }
    
    return JAsyncBuilder.buildWithAdapterFactory(factory)
}

func jffFacebookGraphRequestLoader(accessToken: FBSDKAccessToken, graphPath: String) -> JAsyncTypes<NSDictionary>.JAsync
{
    return jffGenericFacebookGraphRequestLoader(accessToken, graphPath, nil, nil)
}
