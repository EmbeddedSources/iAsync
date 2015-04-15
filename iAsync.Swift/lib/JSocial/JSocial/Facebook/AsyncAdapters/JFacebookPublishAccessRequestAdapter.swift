//
//  JFacebookPublishAccessRequestAdapter.swift
//  JSocial
//
//  Created by Vladimir Gorbenko on 08.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import JAsync

private let cachedAsyncOp = JCachedAsync<HashableDictionary<String,NSObject>, FBSession>()

private class JFacebookPublishAccessRequestAdapter : JAsyncInterface {
    
    let session: FBSession
    let permissions: [String]
    
    init(session: FBSession, permissions: [String]) {
        
        self.session     = session
        self.permissions = permissions
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
        let sessionPermisions = Set(session.permissions as! [String])
        
        let hasAllPermissions = all(permissions) { (permission: String) -> Bool in
        
            return sessionPermisions.contains(permission)
        }
    
        if hasAllPermissions && session.isOpen {
        
            handleLoginWithSession(session, error:nil, finishCallback:finishCallback)
            return
        }
    
        let defaultAudience = FBSessionDefaultAudience.Everyone
    
        if session.isOpen {
            let fbHandler = { (session: FBSession!, error: NSError!) -> () in
            
                let libError = { () -> NSError? in
                    
                    if let error = error {
                        
                        return JFacebookSDKErrors.createFacebookSDKErrorsWithNativeError(error)
                    }
                    return nil
                }()
            
                self.handleLoginWithSession(session, error:libError, finishCallback:finishCallback)
            }
        
            session.requestNewPublishPermissions(
                permissions, defaultAudience:(defaultAudience), completionHandler:fbHandler)
        
            return
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
        
            weakSelf?.handleLoginWithSession(session, error:libError, finishCallback:finishCallback)
        }
    
        FBSession.openActiveSessionWithPublishPermissions(
            permissions,
            defaultAudience  : (defaultAudience),
            allowLoginUI     : true             ,
            completionHandler: fbHandler)
    }
    
    func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    }
    
    private func handleLoginWithSession(
        session: FBSession, error: NSError?, finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback)
    {
        let localError = { () -> NSError? in
            
            if error == nil && !session.isOpen {
                return JFacebookRequestPublishingAccessError()
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

func jffFacebookPublishAccessRequest(session: FBSession, permissions: [String]) -> JAsyncTypes<FBSession>.JAsync
{
    let factory = { () -> JFacebookPublishAccessRequestAdapter in
        
        let object = JFacebookPublishAccessRequestAdapter(session: session, permissions: permissions)
        return object
    }
    
    let loader = JAsyncBuilder.buildWithAdapterFactory(factory)
    
    let mergeParams: HashableDictionary<String,NSObject> = HashableDictionary(dict:
    [
        "method"      : __FUNCTION__,
        "permissions" : Array(Set(permissions))
    ])
    
    return cachedAsyncOp.asyncOpMerger(loader, uniqueKey:mergeParams)
}
