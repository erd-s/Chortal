//
//  AdminSettingsViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/22/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class AdminSettingsViewController: UIViewController {
    //MARK: Properties
    
    
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inviteCodeLabel: UILabel!
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var taskCompletedSwitch: UISwitch!
    @IBOutlet weak var taskTakenSwitch: UISwitch!
    @IBOutlet weak var timeRunningOutSwitch: UISwitch!
    @IBOutlet weak var memberJoinedOrganizationSwitch: UISwitch!
    @IBOutlet weak var taskResubmittedSwitch: UISwitch!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        nameTextField.text = userDefaults.stringForKey("adminName")!
        organizationNameTextField.text = currentOrg!["name"] as? String
        inviteCodeLabel.text = orgUID
        
        if userDefaults.boolForKey("push_taskCompleted")    { taskCompletedSwitch.on = true
                                                     } else { taskCompletedSwitch.on = false }
        if userDefaults.boolForKey("push_taskTaken")        { taskTakenSwitch.on = true
                                                     } else { taskTakenSwitch.on = false }
        if userDefaults.boolForKey("push_timeRunningOut")   { timeRunningOutSwitch.on = true
                                                     } else { timeRunningOutSwitch.on = false }
        if userDefaults.boolForKey("push_memberJoined")     { memberJoinedOrganizationSwitch.on = true
                                                     } else { memberJoinedOrganizationSwitch.on = false }
        if userDefaults.boolForKey("push_taskResubmitted")  { taskResubmittedSwitch.on = true
                                                     } else { taskResubmittedSwitch.on = false }
    }
    
    //MARK: Custom Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: Actions
   
    @IBAction func saveButtonTap(sender: AnyObject) {
        loadingAlert("Saving settings...", viewController: self)
        
        if taskCompletedSwitch.on               { userDefaults.setBool(true, forKey: "push_taskCompleted")
                                         } else { userDefaults.setBool(false, forKey: "push_taskCompleted")}
        if taskTakenSwitch.on                   { userDefaults.setBool(true, forKey: "push_taskTaken")
                                         } else { userDefaults.setBool(false, forKey: "push_taskTaken")}
        if timeRunningOutSwitch.on              { userDefaults.setBool(true, forKey: "push_timeRunningOut")
                                         } else { userDefaults.setBool(false, forKey: "push_timeRunningOut")}
        if memberJoinedOrganizationSwitch.on    { userDefaults.setBool(true, forKey: "push_memberJoined")
                                         } else { userDefaults.setBool(false, forKey: "push_memberJoined")}
        if taskResubmittedSwitch.on             { userDefaults.setBool(true, forKey: "push_taskResubmitted")
                                         } else { userDefaults.setBool(false, forKey: "push_taskResubmitted")}
        
        userDefaults.setValue(nameTextField.text, forKey: "adminName")
        
        if organizationNameTextField.text != currentOrg!["name"] as? String {
            userDefaults.setValue(organizationNameTextField.text, forKey: "currentOrgName")
            currentOrg?.setValue(organizationNameTextField.text, forKey: "name")
            publicDatabase.saveRecord(currentOrg!, completionHandler: { (currentOrg, error) -> Void in
                if error != nil {
                    print("error saving organization name: \(error)")
//----------------->sometimes has an error saving the organization
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: { () -> Void in
                            self.performSegueWithIdentifier("saveAdminSettingsSegue", sender: self)
                        })
                    })
                }
            })
        } else {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.performSegueWithIdentifier("saveAdminSettingsSegue", sender: self)
            })
        }
    }

    @IBAction func copyInviteCode(sender: AnyObject) {
        let pasteboard = UIPasteboard.generalPasteboard()
        pasteboard.string = "\(orgUID!)."
        inviteCodeLabel.text = "Copied!"
    }
    
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    //MARK: Segues
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
