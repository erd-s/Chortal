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
        
    }
    
    //MARK: Custom Functions
    
    
    
    //MARK: IBActions
    @IBAction func joinButtonTap(sender: AnyObject) {
        let predicate = NSPredicate(format: "uid == %@", uidTextField.text!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        
        let cka = CloudKitAccess.init()
        cka.publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error != nil {
                print("Error: \(error?.description)")
            } else {
                if (results != nil) {
                    let record = results![0]
                    print(record.valueForKey("name"))
                    self.record = record
                    print(record.valueForKey("uid"))
                    
                }
            }
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("enterNameSegue", sender: self)
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
            dvc.record = record
            
            
        }
    }
    
}
