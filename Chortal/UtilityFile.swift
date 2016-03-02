//
//  UtilityFile.swift
//  Chortal
//
//  Created by Jonathan Jones on 3/1/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class UtilityFile {
    
    class func instantiateToAdminHome (viewController: UIViewController) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let adminHomeVC = storyboard.instantiateViewControllerWithIdentifier("adminHomeMenu")
        viewController.presentViewController(adminHomeVC, animated: true, completion: nil)
        
    }
    
//    class func instantiateToMemberHome (){
//        
//    }
    
    
}