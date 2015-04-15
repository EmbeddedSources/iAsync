//
//  JAsyncFacebookLogout.swift
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

private class JAsyncFacebookLogout : JAsyncInterface {
    
    private var finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    private var timer: JTimer?
    
    private let renewSystemAuthorization: Bool
    
    typealias ResultType = ()
    
    init(renewSystemAuthorization: Bool) {
        
        self.renewSystemAuthorization = renewSystemAuthorization
    }
    
    var isForeignThreadResultCallback: Bool {
        return false
    }
    
    func logOut() {
        
        manager?.logOut()
        
        let timer = JTimer()
        self.timer = timer
        
        //TODO remove ????
        let cancel = timer.addBlock( { [weak self] (cancel: () -> ()) -> () in
            
            cancel()
            self?.notifyFinished()
        }, duration: 1.0)
    }
    
    var manager: FBSDKLoginManager?
    
    func asyncWithResultCallback(
        finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback: JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        self.finishCallback = finishCallback
        
        let manager = FBSDKLoginManager()
        self.manager = manager
        
        if renewSystemAuthorization {
            
            FBSDKLoginManager.renewSystemCredentials({ (result: ACAccountCredentialRenewResult, error: NSError!) -> Void in
                
                self.logOut()
            })
            return
        }
        
        logOut()
    }
    
    func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    }
    
    func notifyFinished()
    {
        finishCallback?(result: JResult.value(()))
    }
}

func jffFacebookLogout(renewSystemAuthorization: Bool) -> JAsyncTypes<()>.JAsync
{
    let factory = { () -> JAsyncFacebookLogout in
        
        let object = JAsyncFacebookLogout(renewSystemAuthorization: renewSystemAuthorization)
        return object
    }
    
    return JAsyncBuilder.buildWithAdapterFactory(factory)
}
