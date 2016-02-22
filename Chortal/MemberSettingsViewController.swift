//
//  MemberSettingsViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/22/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit

class MemberSettingsViewController: UIViewController {
    //MARK: Properties
    
    
    //MARK: Outlets
    @IBOutlet weak var multipleUsersSwitch: UISwitch!
    @IBOutlet weak var taskApprovedSwitch: UISwitch!
    @IBOutlet weak var taskDeniedSwitch: UISwitch!
    @IBOutlet weak var timeRunningOutSwitch: UISwitch!
    @IBOutlet weak var newTasksAddedSwitch: UISwitch!
    @IBOutlet weak var taskAssignedSwitch: UISwitch!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var defaultPhotoImageView: UIImageView!
    
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        
        if userDefaults.boolForKey("multipleUsers") { multipleUsersSwitch.setOn(true, animated: true) }
        else { multipleUsersSwitch.setOn(false, animated: true) }
        
        if userDefaults.boolForKey("push_taskApproved") { taskApprovedSwitch.setOn(true, animated: true) }
        else { taskApprovedSwitch.setOn(false, animated: true) }
        
        if userDefaults.boolForKey("push_taskDenied") { taskDeniedSwitch.setOn(true, animated: true) }
        else { taskDeniedSwitch.setOn(false, animated: true) }
        
        if userDefaults.boolForKey("push_timeRunningOut") { timeRunningOutSwitch.setOn(true, animated: true) }
        else { timeRunningOutSwitch.setOn(false, animated: true) }
        
        if userDefaults.boolForKey("push_newTasks") { newTasksAddedSwitch.setOn(true, animated: true) }
        else { newTasksAddedSwitch.setOn(false, animated: true) }
        
        if userDefaults.boolForKey("push_taskAssigned") { taskAssignedSwitch.setOn(true, animated: true) }
        else { taskAssignedSwitch.setOn(false, animated: true) }
        
        nameTextField.text = userDefaults.valueForKey("currentUserName") as? String
        
        defaultPhotoImageView.image = currentUser?["photo"] as? UIImage
    }
    
    //MARK: Custom Functions
    
    //MARK: Actions
    @IBAction func changePhotoButtonTap(sender: AnyObject) {
        //open image picker
    }
    
    @IBAction func saveButtonTap(sender: AnyObject) {
        loadingAlert("Saving settings...", viewController: self)
        if multipleUsersSwitch.on { userDefaults.setBool(true, forKey: "multipleUsers") }
        else { userDefaults.setBool(false, forKey: "multipleUsers") }
        
        if taskApprovedSwitch.on { userDefaults.setBool(true, forKey: "push_taskApproved") }
        else { userDefaults.setBool(false, forKey: "push_taskApproved") }
        
        if taskDeniedSwitch.on { userDefaults.setBool(true, forKey: "push_taskDenied") }
        else { userDefaults.setBool(false, forKey: "push_taskDenied") }
        
        if timeRunningOutSwitch.on { userDefaults.setBool(true, forKey: "push_timeRunningOut") }
        else { userDefaults.setBool(false, forKey: "push_timeRunningOut") }
        
        if newTasksAddedSwitch.on { userDefaults.setBool(true, forKey: "push_newTasks") }
        else { userDefaults.setBool(false, forKey: "push_newTasks") }
        
        if taskAssignedSwitch.on { userDefaults.setBool(true, forKey: "push_taskAssigned") }
        else { userDefaults.setBool(false, forKey: "push_taskAssigned") }
        
        if nameTextField.text != userDefaults.valueForKey("currentUserName") as? String {
            userDefaults.setValue(nameTextField.text, forKey: "currentUserName")
            currentUser?.setValue(nameTextField.text, forKey: "name")
            publicDatabase.saveRecord(currentUser!, completionHandler: { (currentUser, error) -> Void in
                if error != nil {
                    print("name not saved, error:\(error)")
                } else {
                    print("saved new username successfully")
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.performSegueWithIdentifier("saveSettingsSegue", sender: self)
                        
                    })
                }
            })
        }
    }
    
    //MARK: Delegate Functions
    
    //MARK: Segues
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
