//
//  UIViewController+PresentTopViewController.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

import JUtils

public extension UIViewController {

    func presentTopViewController(
        viewControllerToPresent: UIViewController,
        animated: Bool,
        completion: JSimpleBlock?
    )
    {
        let presentingController = presentedViewController ?? self
        presentingController.presentViewController(
            viewControllerToPresent,
            animated  : animated,
            completion: completion)
    }
    
    func presentTopViewController(viewControllerToPresent: UIViewController) {
        
        presentTopViewController(viewControllerToPresent, animated:true, completion:nil)
    }
}
