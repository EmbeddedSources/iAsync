//
//  UIImage+ScaleToSize.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

public extension UIImage {
    
    func imageScale(scale: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContext(self.size)
        let currentContext = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(currentContext, self.size.width/2.0, self.size.height/2.0)
        
        CGContextScaleCTM(currentContext, scale, -scale)
        
        let drawRect = CGRectMake(-self.size.width/2.0, -self.size.height/2.0, self.size.width, self.size.height)
        CGContextDrawImage(currentContext, drawRect, self.CGImage)
        let cropped = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cropped
    }
}
