//
//  UIViewController+ForceRemoveFromParentViewController.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

public extension UIViewController {
    
    func forceRemoveFromParentViewController() {
        
        if self.isViewLoaded() && self.view.superview != nil {
            view.removeFromSuperview()
        }
        
        if let parentViewController = parentViewController {
            removeFromParentViewController()
        }
    }
}