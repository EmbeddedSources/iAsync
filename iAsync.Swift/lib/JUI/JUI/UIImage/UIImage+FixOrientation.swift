//
//  UIImage+FixOrientation.swift
//  JUI
//
//  Created by Vladimir Gorbenko on 19.03.15.
//  Copyright (c) 2015 EmbeddedSources. All rights reserved.
//

import Foundation

//source: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload

public extension UIImage {
    
    func fixOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if self.imageOrientation == UIImageOrientation.Up { return self }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransformIdentity
        
        switch self.imageOrientation {
        case UIImageOrientation.Down, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break
            
        case UIImageOrientation.Left, UIImageOrientation.LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break
            
        case UIImageOrientation.Right, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height)
            transform = CGAffineTransformRotate(transform, -CGFloat(M_PI_2))
            break
        case UIImageOrientation.Up, UIImageOrientation.UpMirrored:
            break
        }
        
        switch (self.imageOrientation) {
        case UIImageOrientation.UpMirrored, UIImageOrientation.DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
            
        case UIImageOrientation.LeftMirrored, UIImageOrientation.RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break
        case UIImageOrientation.Up, UIImageOrientation.Down, UIImageOrientation.Left, UIImageOrientation.Right:
            break
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
//        CGBitmapContextCreate(data: UnsafeMutablePointer<Void>, width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace!, bitmapInfo: CGBitmapInfo)
        
        let ctx = CGBitmapContextCreate(
            nil,
            Int(self.size.width),
            Int(self.size.height),
            CGImageGetBitsPerComponent(self.CGImage), 0,
            CGImageGetColorSpace(self.CGImage),
            CGImageGetBitmapInfo(self.CGImage))
        CGContextConcatCTM(ctx, transform)
        
        switch self.imageOrientation {
        case UIImageOrientation.Left,
        UIImageOrientation.LeftMirrored,
        UIImageOrientation.Right,
        UIImageOrientation.RightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage)
            break
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage)
            break
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = CGBitmapContextCreateImage(ctx)
        let img = UIImage(CGImage: cgimg)!
        //CGContextRelease(ctx)
        //CGImageRelease(cgimg)
        return img
    }
}
