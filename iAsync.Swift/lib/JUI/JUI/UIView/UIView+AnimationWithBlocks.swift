//
//  UIView+AnimationWithBlocks.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 17.12.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import UIKit

import JUtils

private let defaultAnimationDuration = 0.2
private let defaultAnimationDelay    = 0.0

public typealias JCompletionBlock = (finished: Bool) -> ()

public extension UIView {

    class func animateWithAnimations(animations: JSimpleBlock) {
    
        animateWithDuration(defaultAnimationDuration, animations:animations)
    }
    
    class func animateWithOptions(options: UIViewAnimationOptions, animations: JSimpleBlock) {
        
        animateWithOptions(options, animations:animations, completion:nil)
    }
    
    class func animateWithOptions(
        options   : UIViewAnimationOptions,
        animations: JSimpleBlock,
        completion: JCompletionBlock?)
    {
        animateWithDuration(
            defaultAnimationDuration,
            delay:defaultAnimationDelay,
            options:options,
            animations:animations,
            completion:completion)
    }
}
