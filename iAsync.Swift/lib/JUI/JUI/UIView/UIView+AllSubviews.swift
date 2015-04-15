//
//  UIView+AllSubviews.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

public extension UIView {
    
    func removeAllSubviews() {
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
