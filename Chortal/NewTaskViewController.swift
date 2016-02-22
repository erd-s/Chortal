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
    var newTask: CKRecord!
    var taskToOrgRef: CKReference!
    var orgToTaskRef: CKReference!
    var currentOrganization: CKRecord!
    
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
    
    func createNewTask() {
        newTask = CKRecord(recordType: "Task")
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
    }
    
    func fetchRecordID() {
        container.fetchUserRecordIDWithCompletionHandler { (record, error) -> Void in
            if error != nil {
                print(error)
            } else {
                self.adminRecordID = record
                let adminRef = CKReference.init(recordID: self.adminRecordID, action: .None)
                self.queryDatabaseForOrganization(adminRef)
            }
        }
    }
    
    func queryDatabaseForOrganization(adminRef: CKReference) {
        let predicate = NSPredicate(format: "uid == %@", orgID!)
        let query = CKQuery(recordType: "Organization", predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil, completionHandler: { (records: [CKRecord]?, error) -> Void in
            if error != nil {
                print(error)
            } else {
                self.currentOrganization = records![0]
                self.orgToTaskRef = CKReference.init(recordID: self.currentOrganization.recordID, action: .None)
                self.taskToOrgRef = CKReference(recordID: self.newTask.recordID, action: .None)
                self.assignReferences()
            }
        })
    }
    
    func assignReferences() {
        let arrayOfTaskRefs = NSMutableArray(object: taskToOrgRef)
        print("arrayoftaskrefs initializes with object: \(taskToOrgRef)")
        
        if currentOrganization.valueForKey("tasks") != nil {
            arrayOfTaskRefs.addObjectsFromArray(currentOrganization.valueForKey("tasks") as! [AnyObject])
            currentOrganization.setObject(arrayOfTaskRefs, forKey: "tasks")
            print("current tasks= \(arrayOfTaskRefs) including: \(taskToOrgRef)")
        } else {
            currentOrganization.setObject(arrayOfTaskRefs, forKey: "tasks")
            print("only added new task: \(taskToOrgRef)")
        }
        newTask.setObject(orgToTaskRef, forKey: "organization")
        newTask.setValue("false", forKey: "inProgress")
        newTask.setValue("false", forKey: "completed")
        print(newTask.valueForKey("inProgress"))
        print(newTask.valueForKey("completed"))
            
        saveTaskAndOrganization([newTask, currentOrganization])
    }
    func saveTaskAndOrganization(records: [CKRecord]) {
        let saveRecordsOp = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
        saveRecordsOp.modifyRecordsCompletionBlock = { saved, deleted, error in
            if error != nil {
                print(error)
            } else {
                print("saved records")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        //   self.performSegueWithIdentifier("createdTaskSegue", sender: self)
                        self.performSegueWithIdentifier("unwindFromTaskCreate", sender: self)
                    })
                }
            }
        }
        publicDatabase.addOperation(saveRecordsOp)
    }
    
    //MARK: IBActions
    @IBAction func createTaskButtonTap(sender: AnyObject) {
        if taskNameTextField.text?.characters.count > 0 {
            loadingAlert("Saving task...", viewController: self)
            createNewTask()
            fetchRecordID() //on completetion --> queries db --> assigns refs --> save records --> segue
        } else {
            let alert = UIAlertController(title: "Error", message: "Please enter a task name.", preferredStyle: .Alert)
            let okay = UIAlertAction(title: "Okay", style: .Default, handler: nil)
            alert.addAction(okay)
            presentViewController(alert, animated: true, completion: nil)
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindFromTaskCreate" {
            let vc = segue.destinationViewController as! AdminHomeViewController
            vc.taskArray.append(newTask)
        }
    }
    
}
