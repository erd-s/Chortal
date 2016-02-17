//
//  NewTaskViewController.swift
//  Chortal
//
//  Created by Christopher Erdos on 2/16/16.
//  Copyright © 2016 JonerDos. All rights reserved.
//

import UIKit
import CloudKit

class NewTaskViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties
    var memberArray = [AnyObject]()
    
    //MARK: Outlets
    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextField: UITextField!
    @IBOutlet weak var incentiveTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var memberSegmentedControl: UISegmentedControl!
    @IBOutlet weak var requirePhotoSwitch: UISwitch!
    
    //MARK: View Loading
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Custom Functions
    
    
    //MARK: IBActions
    @IBAction func createTaskButtonTap(sender: AnyObject) {
        let container = CKContainer.defaultContainer()
        let publicDatabase = container.publicCloudDatabase
        let newTask = CKRecord(recordType: "Task")
        newTask.setObject(datePicker.date, forKey: "due")
        if requirePhotoSwitch.selected {
            newTask.setObject(String("yes"), forKey: "photo_required")
        }
        newTask.setObject(taskDescriptionTextField.text, forKey: "description")
        newTask.setObject(taskNameTextField.text, forKey: "name")
        newTask.setObject(incentiveTextField.text, forKey: "incentive")
        //        newTask.setObject(currentOrganization, forKey: "organization")
        //        let assignedMemberInt = memberSegmentedControl.selectedSegmentIndex
        //        let assignedUser = memberArray[assignedMemberInt]
        //        newTask.setObject(assignedUser, forKey: "member")
        
        publicDatabase.saveRecord(newTask) { (newTask, error) -> Void in
            if error != nil {
                print(error)
            } else {
                print("added \(newTask) to icloud")
            }
        }
    }

    @IBAction func clearSegmentedControlButtonTap(sender: UIButton) {
        memberSegmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    //MARK: Delegate Functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    
    //MARK: Segue
    
    
}
