//
//  UIViewController+Extension.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/23/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func loadingAlert (loadMessage: String, viewController: UIViewController){
        let alert = UIAlertController(title: nil, message: loadMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor.blackColor()
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10,5,50,50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func isICloudContainerAvailable()->Bool {
        if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
            print("trrue")
            return true
            
        } else {
            print("false")
            let alert = UIAlertController(title: "Oops!", message: "Please sign into iCloud and restart the app.", preferredStyle: .Alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .Default, handler: { (UIAlertAction) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            })
            
            alert.addAction(settingsAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
    }

    
    func errorAlert(title: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okay = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(okay)
        self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}