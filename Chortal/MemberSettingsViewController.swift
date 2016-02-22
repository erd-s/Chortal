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
        
        nameTextField.text = userDefaults.valueForKey("currentUserName") as? String
        defaultPhotoImageView.image = currentUser?["photo"] as? UIImage
    }
    
    //MARK: Custom Functions
    
    //MARK: Actions
    @IBAction func changePhotoButtonTap(sender: AnyObject) {
        //open image picker
    }
    
    @IBAction func saveButtonTap(sender: AnyObject) {
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
        }
        
        
        
        performSegueWithIdentifier("saveSettingsSegue", sender: self)
    }
    
    
    
    
    //MARK: Delegate Functions
    
    //MARK: Segues
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
