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
        userDefaults.setValue(uid, forKey: "currentOrgUID")
    }
    
    //MARK: IBActions
    @IBAction func createOrganizationTap(sender: UIButton) {
        let container = CKContainer.defaultContainer()
        let publicDatabase = container.publicCloudDatabase
        let newOrg = CKRecord(recordType: "Organization")
        let newAdmin = CKRecord(recordType: "Admin")
        
        
        let adminOrgRef = CKReference.init(recordID: newOrg.recordID, action: .None)
        newAdmin.setObject(adminOrgRef, forKey: "organization")
        let orgAdminRef = CKReference.init(recordID: newAdmin.recordID, action: .None)
        newOrg.setObject(orgAdminRef, forKey: "admin")
        
        newOrg.setObject(organizationTypeTextField.text, forKey: "type")
        newOrg.setObject(organizationNameTextField.text, forKey: "name")
        newOrg.setObject(adminNameTextField.text, forKey: "admin_name")
        newAdmin.setObject(adminNameTextField.text, forKey: "name")
        setUID(newOrg, admin: newAdmin)
        
        userDefaults.setValue(organizationNameTextField!.text, forKey: "currentOrgName")
        
        publicDatabase.saveRecord(newOrg) { (newOrg, error) -> Void in
            if error != nil {
                print(error)
            } else {
                print("Organization to iCloud: \(newOrg)")
                self.performSegueWithIdentifier("continueToUIDSegue", sender: self)
            }
        }
        publicDatabase.saveRecord(newAdmin) { (newAdmin, error) -> Void in
            if error != nil {
                print(error)
            } else {
                print("Admin to iCloud: \(newOrg)")
            }
        }
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
