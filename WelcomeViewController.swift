//
//  WelcomeViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    //MARK: Properties
    var record: CKRecord?
   
    
    //MARK: Outlets
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(animated: Bool) {
        print("record: \(record)")
        let orgName = record!.valueForKey("name")!
        welcomeLabel.text = "Welcome to \(orgName)"
    }
    
    //MARK: Custom Functions
    func newMember(record: CKRecord) {
        let newMem = CKRecord(recordType: "Member")
        newMem.setValue(nameTextField.text, forKey: "name")
        let orgMemRef = CKReference(recordID: newMem.recordID, action: .None)
        let memOrgRef = CKReference(recordID: record.recordID, action: .None)
        
        newMem.setValue(memOrgRef, forKey: "organization")
        let memArray = record.mutableArrayValueForKey("members")
        memArray.addObject(orgMemRef)
        record.setValue(memArray, forKey: "members")
        
    }
    
    //MARK: IBActions
    
    @IBAction func logInButtonTapped(sender: UIButton) {
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.characters.count > 0 {
            newMember(record!)
        }
        return textField.resignFirstResponder()
    }
    
    //MARK: Segue
    
}
