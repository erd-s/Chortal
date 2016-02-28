//
//  UIImage+Extension.swift
//  Chortal
//
//  Created by Jonathan Jones on 2/28/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func imageWithColor(color: UIColor?) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        if let color = color {
            color.setFill()
        }
        else {
            UIColor.whiteColor().setFill()
        }
        
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
}