//
//  ChortalButton.swift
//  Chortal
//
//  Created by Jonathan Jones on 2/28/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//


import Foundation
import UIKit

class ChortalButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.layer.cornerRadius = 8.0;
        self.layer.borderColor = chortalGreen.CGColor
        self.layer.borderWidth = 0.75
        self.titleLabel?.textColor = chortalGreen
        self.tintColor = chortalGreen
        
        self.setBackgroundImage(UIImage.imageWithColor(chortalGreen), forState: .Highlighted)
        self.setBackgroundImage(UIImage.imageWithColor(.clearColor()), forState: .Normal)
        self.setTitleColor(.grayColor(), forState: .Disabled)
        self.setTitleColor(chortalGreen, forState: .Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        
        self.clipsToBounds = true

    }
}
       
//import UIKit
//import Foundation
//
//class ChortalButton: UIButton {
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)!
//        setup()
//    }
//    
//    
//    
//    func setup() {
//        self.layer.cornerRadius = 5.0;
//        self.layer.borderColor = chortalGreen.CGColor
//        self.layer.borderWidth = 1.5
//        if self.selected == true {
//            self.titleLabel?.textColor = UIColor.whiteColor()
//        } else {
//            self.titleLabel?.textColor = chortalGreen
//        }
//        
//    }
//}