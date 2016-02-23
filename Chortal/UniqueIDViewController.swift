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
    var record: CKRecord?
    
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
        loadingAlert("Joining Group...", viewController: self)
        
        let cka = CloudKitAccess.init()
        cka.publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print("Error: \(error?.description)")
                
            } else {
                if results != nil {
                    if (results!.count > 0) {
                        let record = results![0]
                        print(record.valueForKey("name"))
                        self.record = record
                        print(record.valueForKey("uid"))
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                self.performSegueWithIdentifier("enterNameSegue", sender: self)
                            })
                        }
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                let alert = UIAlertController(title: "Error", message: "Invalid invite code - please try again.", preferredStyle: .Alert)
                                let okay = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                                alert.addAction(okay)
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                        }
                    }
                }
            }
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
            dvc.orgRecord = record
        }
    }
}
