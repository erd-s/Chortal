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
            self.newMem!.setValue(memOrgRef, forKey: "organization")
            
            //saveRecord(newMem!)
            
            orgMemRef = CKReference(recordID: newMem!.recordID, action: .None)
            
            fetchRecord()
            
            
//            var modifiedRecords = [newMem!, self.orgRecord!]
//            let modOpp = CKModifyRecordsOperation.init(recordsToSave: modifiedRecords, recordIDsToDelete: nil)
//            modOpp.savePolicy = .ChangedKeys
//            modOpp.atomic = true
//            ckh.publicDatabase.addOperation(modOpp)
//            
//            modOpp.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                if modOpp.finished == true {
//                    
//                }
//            }
            
            //                        ckh.publicDatabase.saveRecord(record, completionHandler: { (record, error) -> Void in
            //                            if error != nil {
            //                                print("Error: \(error?.description)")
            //                            }
            //                        })
            //
        }
    }
    
    func fetchRecord() {
        ckh.publicDatabase.fetchRecordWithID(orgRecord!.recordID, completionHandler: { (record, error) -> Void in
            
            // Jon - you were in the middle of organizing the below code into separate 'fetch' and 'save' functions. Carefully going through this should hopefully resolve the memory leak and maybe even reveal the issue when attempting to write to CK.
            
            self.orgRecord = record
            
            if self.orgRecord!.mutableArrayValueForKey("members").count == 0 {
                
                self.memArray = [self.orgMemRef!]
                print("Empty key-value pair for Record members")
                print("Organization Members: \(self.memArray)")
                print(self.memArray)
                
            } else {
                
                self.memArray = self.orgRecord!.mutableArrayValueForKey("members")
                self.memArray!.addObject(self.orgMemRef!)
                print("Non-Empty key-value pair for record members")
                
            }
            
            self.orgRecord!.setValue(self.memArray, forKey: "members")
            
            self.saveRecord(self.orgRecord!)
            
        })
    }
    
    func saveRecord (record: CKRecord) {
        ckh.publicDatabase.saveRecord(record, completionHandler: { (completeRecord, error) -> Void in
            if error != nil {
                print("Error: \(error!.description)")
            } else {
                print("Saved successfully: \(record)")
            }
        })
        
        
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
