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
    
    //MARK: Properties
    var orgRecord: CKRecord?
    var newMem: CKRecord?
    let ckh = CloudKitAccess()
    var orgMemRef: CKReference?
    var memOrgRef: CKReference?
    var memArray: NSMutableArray?
    var modifiedRecords: [CKRecord]?
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //MARK: Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var userSwitch: UISwitch!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        memArray = [] as NSMutableArray
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        print("record: \(orgRecord)")
        let orgName = orgRecord!.valueForKey("name")!
        welcomeLabel.text = "Welcome to \(orgName)"
    }
    
    //MARK: Custom Functions
    func newMember(preRecord: CKRecord) {
        if newMem == nil {
            newMem = CKRecord(recordType: "Member")
            newMem!.setValue(nameTextField.text, forKey: "name")
            memOrgRef = CKReference(recordID: orgRecord!.recordID, action: .None)
            newMem!.setValue(memOrgRef, forKey: "organization")
            print("New member Created: \(newMem)")
            
            orgMemRef = CKReference(recordID: newMem!.recordID, action: .None)
            
            fetchRecord()
        }
    }
    
    func fetchRecord() {
        ckh.publicDatabase.fetchRecordWithID(orgRecord!.recordID, completionHandler: { (record, error) -> Void in
            print("Fetching records")
            
            self.orgRecord = record
            
            print(self.orgRecord?.valueForKey("members"))
            
            if self.orgRecord!.mutableArrayValueForKey("members").count == 0 {
                
                self.memArray = [self.orgMemRef!]
                
//                print("Empty key-value pair for Record members")
//                print("Organization Members: \(self.memArray)")
//                print(self.memArray)
                self.orgRecord?.setObject(self.memArray, forKey: "members")
                self.modifyRecords([self.orgRecord!, self.newMem!])

                
            } else {
                
                self.memArray = self.orgRecord!.mutableArrayValueForKey("members")
                self.memArray!.addObject(self.orgMemRef!)
                //self.orgRecord?.setObject(self.memArray, forKey: "members")
                print(self.orgRecord?.objectForKey("members"))
                self.modifyRecords([self.orgRecord!, self.newMem!])
                
            }
            
            
//            print("Members: \(self.orgRecord?.valueForKey("members"))")
//            self.modifiedRecords = [self.orgRecord!, self.newMem!]
//            print("Records to be modified: \(self.modifiedRecords)")
//            self.modifyRecords(self.modifiedRecords!)
            
        })
    }
    
    func modifyRecords (records: [CKRecord]) {
        print("Modify records function called")
        let modOpp = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        modOpp.savePolicy = .ChangedKeys
        modOpp.atomic = true
        
        publicDatabase.addOperation(modOpp)
        
        modOpp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print(error!.description)
                self.errorLabel.numberOfLines = 0
                self.errorLabel.text = "Oops - Something went wrong. Please try again."
                
            }else {
                print("Successfully saved")
                
                self.performSegueWithIdentifier("logInSegue", sender: self)
            }
        }
        
        
        
    }
    //MARK: IBActions
    @IBAction func logInButtonTapped(sender: UIButton) {
        if nameTextField.text?.characters.count > 0 {
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            errorLabel.text = "Working..."
            newMember(orgRecord!)
        }
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logInSegue" {
            
            if userSwitch == true {
                let userName = newMem?.valueForKey("name")
                userDefaults.setValue(userName, forKey: "currentUserName")
                
            } else {
                userDefaults.setValue("Multiple Users", forKey: "currentUserName")
                
            }
            let currentOrgUID = orgRecord?.valueForKey("uid")
            userDefaults.setValue(currentOrgUID, forKey: "currentOrgUID")
            userDefaults.setValue(orgRecord?.valueForKey("name"), forKey: "currentOrgName")
            
        }
    }
    
}
