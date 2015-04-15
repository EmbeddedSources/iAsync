//
//  UIImage+DrawImageInImage.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

public extension UIImage {
    
    func drawInImage(bgImage: UIImage, atPoint point: CGPoint, size: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        bgImage.drawAsPatternInRect(CGRectMake(0.0, 0.0, size.width, size.height))
        drawInRect(CGRectMake(point.x, point.y, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
