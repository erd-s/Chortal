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
    var adminRecordID: CKRecordID!
    var query: CKQuery!
    
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
        
        let tap = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    //MARK: Custom Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
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
        if (requirePhotoSwitch != nil) {
        newTask.setObject("true", forKey: "photo_required")
        } else {
            newTask.setObject("false", forKey: "photo_required")
        }
        
        container.fetchUserRecordIDWithCompletionHandler { (record, error) -> Void in
            if error != nil {
                print(error)
            } else {
                self.adminRecordID = record
                let adminRef = CKReference.init(recordID: self.adminRecordID, action: .None)
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", adminRef)
                self.query = CKQuery(recordType: "Organization", predicate: predicate)
                publicDatabase.performQuery(self.query, inZoneWithID: nil, completionHandler: { (records: [CKRecord]?, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        let ref = CKReference.init(recordID: records![0].recordID, action: .None)
                        newTask.setObject(ref, forKey: "organization")
                        publicDatabase.saveRecord(newTask) { (newTask, error) -> Void in
                            if error != nil {
                                print(error)
                            } else {
                                print("added \(newTask) to icloud")
                            }
                        }
                    }
                })
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
