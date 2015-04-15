//
//  JSocialFBIntegration.swift
//  JSocial
//
//  Created by Vladimir Gorbenko on 30.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

import FBSDKCoreKit

//TODO struct
public class JSocialFBIntegration: NSObject {
    
    static public func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let result = FBSDKApplicationDelegate.sharedInstance().application(
            application, didFinishLaunchingWithOptions: launchOptions)
        
        return result
    }
    
    static public func application(
        application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(
            application,
            openURL: url,
            sourceApplication: sourceApplication,
            annotation: annotation)
    }
    
    static public func activateApp() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

}
