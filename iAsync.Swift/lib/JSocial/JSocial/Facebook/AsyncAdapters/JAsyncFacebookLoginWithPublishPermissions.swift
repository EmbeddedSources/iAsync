//
//  JAsyncFacebookLoginWithPublishPermissions.swift
//  JSocial
//
//  Created by Vladimir Gorbenko on 09.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import JAsync

private let cachedAsyncOp = JCachedAsync<HashableDictionary<String, NSObject>, FBSession>()

private class JAsyncFacebookLoginWithPublishPermissions : JAsyncInterface {

    private let facebookSession: FBSession
    private let permissions    : [String]
    
    init(session: FBSession, permissions: [String]) {
        
        self.facebookSession = session
        self.permissions     = permissions
    }

    typealias ResultType = FBSession

    var isForeignThreadResultCallback: Bool {
        return false
    }

    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        var requstPermissions = Set(permissions)
        let currPermissions   = facebookSession.permissions as! [String]
    
        if facebookSession.isOpen {
        
            let hasAllPermissions = requstPermissions.isSubsetOf(currPermissions)
        
            if hasAllPermissions {
            
                handleLoginWithSession(
                    facebookSession,
                    error:nil,
                    status:facebookSession.state,
                    finishCallback:finishCallback)
                return
            }
        }
    
        var finished = false
        weak var weakSelf = self
    
        let fbHandler = { (session: FBSession!, status: FBSessionState, error: NSError!) -> () in
        
            if finished {
                return
            }
        
            finished = true
        
            let libError = { () -> NSError? in
                
                if let error = error {
                    
                    return JFacebookSDKErrors.createFacebookSDKErrorsWithNativeError(error)
                }
                return nil
            }()
        
            weakSelf?.handleLoginWithSession(session, error:libError, status:status, finishCallback:finishCallback)
        }
    
        FBSession.openActiveSessionWithPublishPermissions(
            Array(requstPermissions),
            defaultAudience: FBSessionDefaultAudience.Everyone,
            allowLoginUI:true,
            completionHandler:fbHandler)
    }
    
    func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    }
    
    private func handleLoginWithSession(
        session: FBSession,
        error: NSError?,
        status: FBSessionState,
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback)
    {
        let localError = { () -> NSError? in
            
            if error == nil && !session.isOpen {
                return JFacebookAuthorizeError()
            }
            
            return error
        }()
        
        if let error = localError {
            
            finishCallback(result: JResult.error(error))
        } else {
            
            finishCallback(result: JResult.value(session))
        }
    }
}

func jffFacebookLoginWithPublishPermissions(session: FBSession, permissions: [String]) -> JAsyncTypes<FBSession>.JAsync
{
    let factory = { () -> JAsyncFacebookLoginWithPublishPermissions in
        
        return JAsyncFacebookLoginWithPublishPermissions(session: session, permissions: permissions)
    }
    
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    let mergeParams: HashableDictionary<String,NSObject> = HashableDictionary(dict:
    [
        "method"      : __FUNCTION__,
        "permissions" : Array(Set(permissions)),
    ])
    
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey:mergeParams)
}
