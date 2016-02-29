//
//  UniqueIDViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class UniqueIDViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    var orgRecordToJoin: CKRecord?
    
    //MARK: Outlets
    @IBOutlet weak var uidTextField: UITextField!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //MARK: Custom Functions
    func dismissKeyboard(){
        self.setEditing(false, animated: true)
    }
    
    //MARK: IBActions
    @IBAction func joinButtonTap(sender: AnyObject) {
        
        uidTextField.resignFirstResponder()
        
        let predicate = NSPredicate(format: "uid == %@", uidTextField.text!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        isICloudContainerAvailable()
        loadingAlert("Joining Group...", viewController: self)
        
        
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print("error getting organization: \(error)")
            } else {
                if results != nil {
                    if (results!.count > 0) {
                        self.orgRecordToJoin = results![0]
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                self.performSegueWithIdentifier("enterNameSegue", sender: self)
                            })
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                self.errorAlert("Oops!", message: "That invite code doesn't exist. Please try again.")
                            })
                        }
                    }
                }
            }
        }
    }
    
    
func isICloudContainerAvailable()->Bool {
if let _ = NSFileManager.defaultManager().ubiquityIdentityToken {
    return true
        } else {
    self.errorAlert("Oops!" , message: "Please set your iCloud account in your settings first.")
       return false
    
        }

    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enterNameSegue" {
            let dvc = segue.destinationViewController as! WelcomeViewController
            dvc.orgRecord = orgRecordToJoin
        }
    }
}
