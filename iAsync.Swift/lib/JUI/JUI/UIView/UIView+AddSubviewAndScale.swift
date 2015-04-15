//
//  UIView+AddSubviewAndScale.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 03.01.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import UIKit

public extension UIView {

    func addSubviewAndScale(view: UIView) {
        
        view.removeFromSuperview()
    
        view.frame = self.bounds
        view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        addSubview(view)
    }
}
