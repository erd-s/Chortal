//
//  CreateOrganizationViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class CreateOrganizationViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    var uid: String!
    
    
    //MARK: Outlets
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var adminNameTextField: UITextField!
    @IBOutlet weak var adminPasswordTextField: UITextField!
    @IBOutlet weak var organizationTypeTextField: UITextField!
    
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
    
    func setUID(organization: CKRecord, admin: CKRecord) {
        let timestamp = String(NSDate.timeIntervalSinceReferenceDate())
        let timestampParts = timestamp.componentsSeparatedByString(".")
        uid = timestampParts[0]
        uid.appendContentsOf(timestampParts[1])
        organization.setObject(uid, forKey: "uid")
        admin.setObject(uid, forKey: "uid")
    }
    
    func setUserDefaults() {
        userDefaults.setBool(true, forKey: "push_taskCompleted")
        userDefaults.setBool(true, forKey: "push_taskTaken")
        userDefaults.setBool(true, forKey: "push_timeRunningOut")
        userDefaults.setBool(true, forKey: "push_memberJoined")
        userDefaults.setBool(true, forKey: "push_taskResubmitted")
        userDefaults.setBool(true, forKey: "isAdmin")
        userDefaults.setValue(uid, forKey: "currentOrgUID")
        userDefaults.setValue(organizationNameTextField!.text, forKey: "currentOrgName")
        userDefaults.setValue(adminNameTextField.text, forKey: "adminName")
    }
    
    func saveRecords(recordsToSave: [CKRecord]) {
        let saveOperation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: nil)
        
        saveOperation.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                print(error)
            } else {
                if saved != nil {
                    print("Saved Record: \(saved)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.performSegueWithIdentifier("continueToUIDSegue", sender: self)
                        })
                    })
                }
            }
        }
        publicDatabase.addOperation(saveOperation)
    }
    
    //MARK: IBActions
    @IBAction func createOrganizationTap(sender: UIButton) {
        loadingAlert("Creating Organization...", viewController: self)
        let newOrg = CKRecord(recordType: "Organization")
        let newAdmin = CKRecord(recordType: "Admin")
        
        let orgRef = CKReference.init(recordID: newOrg.recordID, action: .None)
        newAdmin.setObject(orgRef, forKey: "organization")
        
        let adminRef = CKReference.init(recordID: newAdmin.recordID, action: .None)
        newOrg.setObject(adminRef, forKey: "admin")
        
        newOrg.setObject(organizationTypeTextField.text, forKey: "type")
        newOrg.setObject(organizationNameTextField.text, forKey: "name")
        newOrg.setObject(adminNameTextField.text, forKey: "admin_name")
        newAdmin.setObject(adminNameTextField.text, forKey: "name")
        
        setUID(newOrg, admin: newAdmin)
        setUserDefaults()
        saveRecords([newOrg, newAdmin])
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "continueToUIDSegue" {
            let dvc = segue.destinationViewController as! AssignUIDViewController
            dvc.orgUID = uid
        }
    }
    
}
