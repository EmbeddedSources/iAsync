//
//  JAsyncFacebookDialog.swift
//  JSocial
//
//  Created by Vladimir Gorbenko on 09.10.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils
import JAsync

import FBSDKShareKit

@objc public class JAsyncFacebookShareDialog: NSObject, JAsyncInterface, FBSDKSharingDelegate {
    
    private let viewController: UIViewController
    private let contentURL    : NSURL
    private let usersIDs      : [String]
    private let title         : String
    
    init(
        viewController: UIViewController,
        contentURL    : NSURL,
        usersIDs      : [String],
        title         : String)
    {
        self.viewController = viewController
        self.contentURL     = contentURL
        self.usersIDs       = usersIDs
        self.title          = title
    }
    
    public typealias ResultType = Void
    
    private var shareDialog: FBSDKShareDialog? = nil
    
    private var finishCallback: JAsyncTypes<ResultType>.JDidFinishAsyncCallback?
    
    public func asyncWithResultCallback(
        finishCallback  : JAsyncTypes<ResultType>.JDidFinishAsyncCallback,
        stateCallback   : JAsyncChangeStateCallback,
        progressCallback: JAsyncProgressCallback)
    {
        self.finishCallback = finishCallback
        
        let content = FBSDKShareLinkContent()
        
        content.peopleIDs    = usersIDs
        content.contentURL   = contentURL
        content.contentTitle = title
        
        shareDialog = FBSDKShareDialog.showFromViewController(
            viewController,
            withContent: content,
            delegate   : self)
    }
    
    public func doTask(task: JAsyncHandlerTask)
    {
        assert(task.rawValue <= JAsyncHandlerTask.Cancel.rawValue)
    }
    
    public var isForeignThreadResultCallback: Bool {
        return false
    }
    
    @objc public func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!)
    {
        finishCallback?(result: JResult.value(()))
    }
    
    public func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!)
    {
        finishCallback?(result: JResult.error(error))
    }
    
    public func sharerDidCancel(sharer: FBSDKSharing!)
    {
        finishCallback?(result: JResult.error(JAsyncFinishedByCancellationError()))
    }
}

func jffShareFacebookDialog(
    viewController: UIViewController,
    contentURL    : NSURL,
    usersIDs      : [String],
    title         : String) -> JAsyncTypes<()>.JAsync
{
    let factory = { () -> JAsyncFacebookShareDialog in
        
        return JAsyncFacebookShareDialog(
            viewController: viewController,
            contentURL    : contentURL    ,
            usersIDs      : usersIDs      ,
            title         : title)
    }
    
    return JAsyncBuilder.buildWithAdapterFactory(factory)
}
