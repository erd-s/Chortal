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
    
    //MARK: Outlets
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        memArray = [] as NSMutableArray
    }
    
    override func viewWillAppear(animated: Bool) {
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
           // saveRecord(newMem!)
            
            orgMemRef = CKReference(recordID: newMem!.recordID, action: .None)
            
            fetchRecord()
        }
    }
    
    func fetchRecord() {
        ckh.publicDatabase.fetchRecordWithID(orgRecord!.recordID, completionHandler: { (record, error) -> Void in
            
            // Jon - you were in the middle of organizing the below code into separate 'fetch' and 'save' functions. Carefully going through this should hopefully resolve the memory leak and maybe even reveal the issue when attempting to write to CK.
            
            print("Fetching records")
            
            self.orgRecord = record
            
            if self.orgRecord!.mutableArrayValueForKey("members").count == 0 {
                
                self.memArray = [self.orgMemRef!]
                
                print("Empty key-value pair for Record members")
                print("Organization Members: \(self.memArray)")
                print(self.memArray)
                
            } else {
                
                self.memArray = self.orgRecord!.mutableArrayValueForKey("members")
                self.memArray!.addObject(self.orgMemRef!)
                print("Non-Empty key-value pair for record members: \(self.memArray)")
            }
            
            print("Members: \(self.orgRecord?.valueForKey("members"))")
        //    self.orgRecord!.setValue(self.memArray, forKey: "members")
       //     print("Org Mem Value: \(self.orgRecord)")
            self.modifiedRecords = [self.orgRecord!, self.newMem!]
            print("Records to be modified: \(self.modifiedRecords)")
            
            self.modifyRecords(self.modifiedRecords!)
         //   self.saveRecord(self.orgRecord!)
            
        })
    }
    
    func modifyRecords (records: [CKRecord]) {
        print("Modify records function called")
        let modOpp = CKModifyRecordsOperation.init(recordsToSave: modifiedRecords, recordIDsToDelete: nil)
        modOpp.savePolicy = .ChangedKeys
        modOpp.atomic = true
        modOpp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                print(error!.description)
            }else {
                print("Successfully saved")
            }
        }
        ckh.publicDatabase.addOperation(modOpp)

        
    }
    //MARK: IBActions
    @IBAction func logInButtonTapped(sender: UIButton) {
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text?.characters.count > 0 {
            newMember(orgRecord!)
        }
        return textField.resignFirstResponder()
    }
    
    //MARK: Segue
    
}
